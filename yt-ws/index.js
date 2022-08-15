import { existsSync, mkdirSync, readFileSync, writeFileSync, createWriteStream } from 'fs';
import { WebSocketServer } from 'ws';
import Innertube from 'youtubei.js';
import axios from 'axios';

const { env } = process;

const homeDir = env.HOME;
const xdgConfig = env.XDG_CONFIG_HOME || (homeDir ? `${homeDir}/.config` : undefined);
const xdgData = env.XDG_DATA_HOME || (homeDir ? `${homeDir}/.local/share` : undefined);

// Too show. Needs to be converted to async
const appPath = `${xdgConfig}/cathode-tube.walking-octopus`;
if (!existsSync(appPath)) {
  mkdirSync(appPath);
}

const videoDownloadDir = `${xdgData}/cathode-tube.walking-octopus`;
if (!existsSync(videoDownloadDir)) {
  mkdirSync(videoDownloadDir);
}

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

      switch (json.topic) {
        case 'GetFeed': {
          const feedType = json.payload;
          let feed;

          switch (feedType) {
            case 'Home': {
              feed = await youtube.getHomeFeed();
              feed.feedType = 'Home';
              break;
            }

            case 'Subscriptions': {
              feed = await youtube.getSubscriptionsFeed();
              feed.feedType = 'Subscriptions';
              break;
            }

            case 'Trending': {
              feed = await youtube.getTrending();
              feed.feedType = 'Trending';
              break;
            }

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
          const playlist = await youtube.getPlaylist(json.payload);

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
            // FIXME: No new commands are processed after `break`. Maybe `continue` would help.
            break;
          }

          const continuation = await lastFeed.getContinuation();
          continuation.feedType = lastFeed.feedType;
          ws.send(JSON.stringify(
            newMessage('continuationEvent', continuation),
          ));
          lastFeed = continuation;

          break;
        }

        case 'GetNotifications': {
          const notifications = await youtube.getNotifications();

          ws.send(JSON.stringify(
            newMessage('notificationsEvent', notifications),
          ));

          break;
        }

        case 'GetSearchSuggestions': {
          if (json.payload === '') {
            break;
          }

          const suggestions = await youtube.getSearchSuggestions(json.payload);
          ws.send(JSON.stringify(
            newMessage('searchSuggestionsEvent', suggestions),
          ));

          break;
        }

        case 'GetSearchResults': {
          if (json.payload === '') {
            break;
          }

          const results = await youtube.search(json.payload);
          ws.send(JSON.stringify(
            newMessage('searchResultsEvent', results),
          ));

          break;
        }

        case 'GetStreamingData': {
          if (json.payload.id === '') {
            break;
          }

          try {
            const qualityData = await youtube.getStreamingData(json.payload.id, {
              quality: json.payload.quality,
            });

            ws.send(JSON.stringify(
              newMessage('streamingDataEvent', qualityData),
            ));
          } catch {
            ws.send(JSON.stringify(
              newMessage('error', new Error("Can't fetch video stream").message),
            ));
          }

          break;
        }

        case 'GetVideoDetails': {
          if (json.payload.id === '') {
            break;
          }

          const videoDetails = await youtube.getDetails(json.payload.id);
          const returnYouTubeDislike = await axios.get(`https://returnyoutubedislikeapi.com/votes?videoId=${json.payload.id}`);

          videoDetails.metadata.view_count = Intl.NumberFormat('en-US', {
            notation: 'compact',
            maximumFractionDigits: 1,
          }).format(videoDetails.metadata.view_count);

          videoDetails.metadata.rating = returnYouTubeDislike.data.rating;

          videoDetails.metadata.dislikes = {
            count: returnYouTubeDislike.data.dislikes,
            short_count_text: Intl.NumberFormat('en-US', {
              notation: 'compact',
              maximumFractionDigits: 1,
            }).format(returnYouTubeDislike.data.dislikes),
          };

          ws.send(JSON.stringify(
            newMessage('videoDetailsEvent', videoDetails),
          ));

          break;
        }

        case 'SetRating': {
          if (json.payload.id === '') {
            break;
          }

          switch (json.payload.action) {
            case 'Like': {
              await youtube.interact.like(json.payload.id);

              ws.send(JSON.stringify(
                newMessage('ratingEvent', {
                  type: 'Like',
                }),
              ));

              break;
            }

            case 'RemoveRating': {
              await youtube.interact.removeLike(json.payload.id);

              ws.send(JSON.stringify(
                newMessage('ratingEvent', {
                  type: 'RemoveRating',
                }),
              ));

              break;
            }

            case 'Dislike': {
              await youtube.interact.dislike(json.payload.id);

              ws.send(JSON.stringify(
                newMessage('ratingEvent', {
                  type: 'Dislike',
                }),
              ));

              // TODO: Submit the vote to Return YouTube Dislike

              break;
            }

            default: {
              break;
            }
          }

          break;
        }

        case 'SetSubscription': {
          if (json.payload.channel_id === '') {
            break;
          }

          if (json.payload.isSubscribed) {
            await youtube.interact.subscribe(json.payload.channel_id);
          } else {
            await youtube.interact.unsubscribe(json.payload.channel_id);
          }

          ws.send(JSON.stringify(
            newMessage('updateSubscription', json.payload.isSubscribed),
          ));

          break;
        }

        case 'DownloadVideo': {
          if (json.payload.video_id === '' || json.payload.video_title === '' || json.payload.quality === '') {
            break;
          }

          const stream = youtube.download(json.payload.video_id, {
            quality: json.payload.quality,
            format: 'mp4',
            type: 'videoandaudio',
          });

          stream.pipe(createWriteStream(`${videoDownloadDir}/${json.payload.video_title}.mp4`));

          stream.on('progress', (info) => {
            // TODO: Add file size info
            ws.send(JSON.stringify(
              newMessage('videoDownloadEvent', info.percentage),
            ));
          });

          stream.on('error', (err) => console.error('[DOWNLOAD ERROR]', err));

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
