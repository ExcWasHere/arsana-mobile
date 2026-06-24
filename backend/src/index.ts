import { Hono } from 'hono';
import { cors } from 'hono/cors';
import profile from './routes/profile.js';

type Bindings = {
  SUPABASE_URL: string;
  SUPABASE_SERVICE_ROLE_KEY: string;
};

const app = new Hono<{ Bindings: Bindings }>();

app.use('*', cors());
app.route('/profile', profile);

export default app;