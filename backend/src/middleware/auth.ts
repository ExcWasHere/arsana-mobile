import { Context, type Next } from 'hono';
import { makeSupabaseAdmin } from '../lib/supabase.js';

export async function requireAuth(c: Context, next: Next) {
  const authHeader = c.req.header('Authorization');
  if (!authHeader?.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401);
  }
  const token = authHeader.replace('Bearer ', '');
  const supabase = makeSupabaseAdmin(c.env as any);
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    return c.json({ error: 'Unauthorized' }, 401);
  }
  c.set('userId', data.user.id);
  await next();
}