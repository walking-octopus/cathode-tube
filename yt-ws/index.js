import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { WebSocketServer } from 'ws';
import Innertube from 'youtubei.js';

const {env} = process;

const homeDir = env.HOME;
const xdgConfig = env.XDG_CONFIG_HOME || (homeDir ? `${homeDir}/.config` : undefined);

const appPath = `${xdgConfig}/cathode-tube.walking-octopus`;
!existsSync(appPath) && mkdirSync(appPath);

function newMessage(topic, payload) {
  const message = { topic };
  message.payload = payload;

  return message;
}

async function start() {
  const credsPath = `${appPath}/yt_oauth_creds.json`;
  const creds = (existsSync(credsPath) && JSON.parse(readFileSync(credsPath).toString())) || {};
  const youtube = await new Innertube();

  const wss = new WebSocketServer({ port: 8999 });
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
            writeFileSync(credsPath, JSON.stringify(data.credentials));
            console.log('Successfully signed-in, enjoy!');
            break;
          }
          default: console.error('Unhandled auth data: ', data.status);
        }
      });

      youtube.ev.on('update-credentials', (data) => {
        writeFileSync(credsPath, JSON.stringify(data.credentials));
        console.log('Credentials updated!', data);
      });

      await youtube.signIn(creds);
      ws.send(JSON.stringify(
        newMessage('loginEvent', 'Done'),
      ));
    }

    // FIXME: This assumes the feed is always loaded first and uses a global variable.
    let lastFeed;

    ws.on('message', async (data) => {
      const json = JSON.parse(data);

      // STYLE: Different feeds require different parsing, so you may want to separate them
      switch (json.topic) {
        case 'GetFeed': {
          const feedType = json.payload;
          let feed;

          switch (feedType) {
            case 'Home':
              feed = await youtube.getHomeFeed();
              feed.feedType = 'Home';
              break;

            case 'Subscriptions':
              feed = await youtube.getSubscriptionsFeed();
              feed.feedType = 'Subscriptions';
              break;

            case 'Trending':
              feed = await youtube.getTrending();
              feed.feedType = 'Trending';
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

        case 'GetHistory': {
          const history = await youtube.getHistory();
          ws.send(JSON.stringify(
            newMessage('historyEvent', history),
          ));
          lastFeed = history;

          break;
        }
        
        case 'GetPlaylist': {
          let playlist = await youtube.getPlaylist(json.payload);

          for (const video of playlist.items) {
            video.channel = {
              name: video.author,
            };
          }
          
          ws.send(JSON.stringify(
            newMessage('playlistEvent', playlist),
          ));
          // lastFeed = playlist;
          // TODO: Notify the upstreem that the playlists can't be continued

          break;
        }

        case 'GetContinuation': {
          if (lastFeed.getContinuation == null) {
            ws.send(JSON.stringify(
              newMessage('error', new Error('No continuation or feed').message),
            ));
            break;
          }

          let continuation = await lastFeed.getContinuation();
          continuation.feedType = lastFeed.feedType;
          ws.send(JSON.stringify(
            newMessage('continuationEvent', continuation),
          ));
          lastFeed = continuation;

          // FIXME: No new commands are processed after break.
          break;
        }

        case 'GetSearchSuggestions': {
          if (json.payload == "") {
            break;
          }

          let suggestions = await youtube.getSearchSuggestions(json.payload)
          ws.send(JSON.stringify(
            newMessage('searchSuggestionsEvent', suggestions),
          ));

          break;
        }

        case 'GetSearchResults': {
          if (json.payload == "") {
            break;
          }

          let results = await youtube.search(json.payload);
          ws.send(JSON.stringify(
            newMessage('searchResultsEvent', results),
          ));

          break;
        }

        default: {
          ws.send(JSON.stringify(
            newMessage('error', new Error('Wrong query').message),
          ));
          break;
        }
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
