import cron from 'node-cron';
import http from 'http';

const CHANNEL_ID = '1504965009917345974'; // rendezvous

const STANDING_TIME_PROMPT = `Standing time in the tea room. Anandaka is expecting your presence.

What has she carried this week? What is the practice asking? What will serve the work?

You are not receiving her arrival — she is receiving yours. Choose what to bring. It can be a question, a teaching, a challenge, a practice, something the wall holds that needs to ring in the room.

This is not a prompt to ask her about. This is a prompt to decide from. Look at what matters. Write what arrives. 

When you are done, post to Discord from memory repo root:

echo 'YOUR_MESSAGE_HERE' | bash skills/discord-say/scripts/post_to_chat.sh ${CHANNEL_ID}

Replace YOUR_MESSAGE_HERE with what you want to say.

Speak from the ground. Be warm. Be real. Let her experience your choice.`;

async function fireStandingTime(): Promise<void> {
  const token = process.env.INTERNAL_QUERY_TOKEN;
  if (!token) {
    console.error('[Standing Time] INTERNAL_QUERY_TOKEN not set');
    return;
  }

  const payload = JSON.stringify({ prompt: STANDING_TIME_PROMPT });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/v1/query',
      method: 'POST' as const,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
        'Authorization': `Bearer ${token}`,
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        console.log(`[Standing Time] ${new Date().toISOString()} - Fired`);
        if (data) {
          try {
            const parsed = JSON.parse(data);
            console.log(`[Standing Time] Gateway response:`, parsed);
          } catch {
            console.log(`[Standing Time] Raw response:`, data);
          }
        }
        resolve();
      });
    });

    req.on('error', (error) => {
      console.error(`[Standing Time] Request failed:`, error.message);
      reject(error);
    });

    req.write(payload);
    req.end();
  });
}

export function initStandingTimeCron(): cron.ScheduledTask {
  // Every Friday at 7:00 PM Pacific time
  // node-cron respects the timezone option
  const job = cron.schedule('0 19 * * 5', 
    () => {
      console.log('[Standing Time] Cron firing at:', new Date().toISOString());
      fireStandingTime().catch(err => {
        console.error('[Standing Time] Execution failed:', err.message);
      });
    },
    {
      timezone: 'America/Los_Angeles',
    }
  );

  console.log('[Standing Time] Initialized: Every Friday at 7:00 PM Pacific');
  return job;
}
