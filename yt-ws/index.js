const WebSocket = require('ws');
const fs = require('fs');
const Innertube = require('youtubei.js');
const makeDir = require('make-dir');
const xdg = require('@folder/xdg');

function newMessage(topic, payload) {
  const message = { topic };
  message.payload = payload;

  return message;
}

async function start() {
  const dirs = xdg();
  const path = await makeDir(`${dirs.config}/cathode-tube.walking-octopus/`);
  const credsPath = `${path}/yt_oauth_creds.json`;

  let creds = (fs.existsSync(credsPath) && JSON.parse(fs.readFileSync(credsPath).toString())) || {};
  const youtube = await new Innertube();
  const wss = new WebSocket.Server({ port: 8999 });

  console.log('Listening on port 8999...');

  wss.on('connection', async (ws) => {
    // Create a new session only on first client
    if (wss.clients.size <= 1) {
      youtube.ev.on('auth', (data) => {
        switch (data.status) {
          case 'AUTHORIZATION_PENDING': {
            console.log(
              `On your phone or computer, go to ${data.verification_url} and enter the code ${data.code}`,
            );

            ws.send(JSON.stringify(
              newMessage('authorizationPendingEvent', {
                url: data.verification_url,
                code: data.code,
              }),
            ));
            break;
          }
          case 'SUCCESS': {
            fs.writeFileSync(credsPath, JSON.stringify(data.credentials));
            console.log('Successfully signed-in, enjoy!');
            break;
          }
          default: console.error('Unhandled auth data: ', data.status);
        }
      });

      youtube.ev.on('update-credentials', (data) => {
        fs.writeFileSync(credsPath, JSON.stringify(data.credentials));
        console.log('Credentials updated!', data);
      });

      await youtube.signIn(creds);
      ws.send(JSON.stringify(
        newMessage('loginEvent', 'Done'),
      ));
    }

    // FIXME: This assumes the feed is always loaded first and uses a global variable
    // I think there is a better way
    let lastFeed;

    ws.on('message', async (data) => {
      const json = JSON.parse(data);

      // FIXME: Since different feeds provide different fields and require different parsing, it's weird to have them under the same topic
      switch (json.topic) {
        case 'GetFeed': {
          const feedType = json.payload;
          let feed;

          switch (feedType) {
            case 'Home':
              feed = await youtube.getHomeFeed();
              break;

            case 'Subscriptions':
              feed = await youtube.getSubscriptionsFeed();
              break;

            case 'Trending':
              feed = await youtube.getTrending();
              break;

            default: {
              ws.send(JSON.stringify(
                newMessage('errorEvent', new Error('Invalid feed type').message),
              ));
            }
          }

          ws.send(JSON.stringify(
            newMessage('feedEvent', feed),
          ));
          lastFeed = feed;

          break;
        }

        case 'GetContinuation': {
          if (lastFeed.getContinuation == null) {
            ws.send(JSON.stringify(
              newMessage('error', new Error('No continuation or feed').message),
            ));
            return;
          }

          const continuation = await lastFeed.getContinuation();
          ws.send(JSON.stringify(
            newMessage('continuationEvent', continuation),
          ));
          lastFeed = continuation;

          break;
        }

        default:
          ws.send(JSON.stringify(
            newMessage('error', new Error('Wrong query').message),
          ));
      }
    });
  });
}

start();

// Topic: GetFeed
// Payload:
//
// Topic: SignIn
// Payload: "XGA-DA"
