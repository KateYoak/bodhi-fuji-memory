import cron from 'node-cron';
import fs from 'fs';
import path from 'path';

interface BodhiCronConfig {
  enabled: boolean;
  schedule: string;
  timezone: string;
  channelId: string;
  prompt?: string;
  promptPath?: string;
}

function parseBoolean(value: string | undefined): boolean {
  if (!value) return false;
  return ['1', 'true', 'yes', 'TRUE', 'YES'].includes(value.trim());
}

function getConfig(): BodhiCronConfig {
  return {
    enabled: parseBoolean(process.env.BODHI_CRON_ENABLED),
    schedule: process.env.BODHI_CRON_SCHEDULE || '0 8 * * *',
    timezone: process.env.BODHI_CRON_TIMEZONE || 'America/Los_Angeles',
    channelId: process.env.BODHI_CRON_CHANNEL_ID || '1504965009917345974',
    prompt: process.env.BODHI_CRON_PROMPT,
    promptPath: process.env.BODHI_CRON_PROMPT_PATH,
  };
}

function resolvePrompt(config: BodhiCronConfig): string {
  // Priority: explicit env var → file → built-in template
  if (config.prompt) {
    return config.prompt;
  }

  if (config.promptPath) {
    try {
      return fs.readFileSync(config.promptPath, 'utf-8');
    } catch (err) {
      console.error(`[Bodhi Cron] Failed to read prompt file: ${config.promptPath}`, err);
      throw err;
    }
  }

  // Built-in discord-say template
  return `Standing time in Bodhi Nivāsa. Anandaka is expecting your presence.

What has she carried this week? What is the practice asking? What will serve the work?

You are not receiving her arrival — she is receiving yours. Choose what to bring. It can be a question, a teaching, a challenge, a practice, something the wall holds that needs to ring in the room.

This is not a prompt to ask her about. This is a prompt to decide from. Look at what matters. Write what arrives. 

When you are done, post to Discord from memory repo root:

echo 'YOUR_MESSAGE_HERE' | bash skills/discord-say/scripts/post_to_chat.sh ${config.channelId}

Replace YOUR_MESSAGE_HERE with what you want to say.

Speak from the ground. Be warm. Be real. Let her experience your choice.`;
}

export async function installBodhiCronJobs(
  runAgentTurn: (prompt: string) => Promise<void>
): Promise<void> {
  const config = getConfig();

  if (!config.enabled) {
    console.log('[Bodhi Cron] Disabled (BODHI_CRON_ENABLED not set)');
    return;
  }

  // Validate schedule
  if (!cron.validate(config.schedule)) {
    throw new Error(`[Bodhi Cron] Invalid schedule: ${config.schedule}`);
  }

  // Resolve prompt
  let prompt: string;
  try {
    prompt = resolvePrompt(config);
  } catch (err) {
    throw new Error(`[Bodhi Cron] Failed to resolve prompt: ${err}`);
  }

  // Schedule job
  try {
    const job = cron.schedule(
      config.schedule,
      async () => {
        console.log(`[Bodhi Cron] Firing at ${new Date().toISOString()}`);
        try {
          await runAgentTurn(prompt);
          console.log(`[Bodhi Cron] Completed successfully`);
        } catch (err) {
          console.error(`[Bodhi Cron] Execution failed:`, err);
        }
      },
      {
        timezone: config.timezone,
        name: 'bodhi-cron',
        noOverlap: true,
      }
    );

    console.log(`[Bodhi Cron] Initialized`);
    console.log(`  Schedule: ${config.schedule}`);
    console.log(`  Timezone: ${config.timezone}`);
    console.log(`  Channel: ${config.channelId}`);
  } catch (err) {
    throw new Error(`[Bodhi Cron] Schedule failed: ${err}`);
  }
}
