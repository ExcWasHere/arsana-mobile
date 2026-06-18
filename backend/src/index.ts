import { Hono } from 'hono';
import { cors } from 'hono/cors';
import profile from './routes/profile.js';

const app = new Hono();

app.use('*', cors());
app.route('/profile', profile);

export default app;