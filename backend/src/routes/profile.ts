import { Hono } from 'hono';
import { requireAuth } from '../middleware/auth.js';
import { supabaseAdmin } from '../lib/supabase.js';

const profile = new Hono<{ Variables: { userId: string } }>();

profile.post('/', requireAuth, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();

  const { error } = await supabaseAdmin.from('profiles').upsert({
    id: userId,
    full_name: body.fullName,
    birth_date: body.birthDate,
    city: body.city,
    school: body.school,
  });

  if (error) return c.json({ error: error.message }, 400);
  return c.json({ success: true }, 201);
});

profile.get('/me', requireAuth, async (c) => {
  const userId = c.get('userId') as string;
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .maybeSingle();

  if (error) return c.json({ error: error.message }, 400);
  return c.json({ profile: data });
});

export default profile;