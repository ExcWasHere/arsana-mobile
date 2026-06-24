import { Hono } from 'hono';
import { requireAuth } from '../middleware/auth.js';
import { makeSupabaseAdmin } from '../lib/supabase.js';

type Bindings = {
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
};

const profile = new Hono<{ Bindings: Bindings; Variables: { userId: string } }>();

profile.post('/', requireAuth, async (c) => {
  const userId = c.get('userId');
  const body = await c.req.json();
  const supabase = makeSupabaseAdmin(c.env);

  const { error } = await supabase.from('profiles').upsert({
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
  const userId = c.get('userId');
  const supabase = makeSupabaseAdmin(c.env);

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .maybeSingle();

  if (error) return c.json({ error: error.message }, 400);
  return c.json({ profile: data });
});

export default profile;