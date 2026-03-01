// =============================================
//  LI7ERAE — GUARDA DE SEGURANÇA DAS PÁGINAS 🔒
//
//  Adicione esta linha no <head> de cada página
//  que precisa estar logado para acessar:
//
//  <script type="module" src="/auth-guard.js"></script>
//
//  Para páginas só de admin, use:
//  <script>window.LI7_ADMIN_ONLY = true;</script>
//  <script type="module" src="/auth-guard.js"></script>
// =============================================

import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

// ⚠️ Mesmos valores do login.html
const SUPABASE_URL = 'https://edoozioyoyvxthzuyduo.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVkb296aW95b3l2eHRoenV5ZHVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzOTY5NDAsImV4cCI6MjA4Nzk3Mjk0MH0.SmlVBnq9Rr4E96u--R3bD_u7PwWsr8G6RmXL2M848t4';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
window.supabaseClient = supabase;

async function init() {
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    window.location.href = '/login';
    return;
  }

  const user = session.user;

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (window.LI7_ADMIN_ONLY && profile?.role !== 'admin') {
    window.location.href = '/area';
    return;
  }

  window.LI7_USER    = user;
  window.LI7_PROFILE = profile;

  preencherUI(profile, user);

  document.dispatchEvent(new CustomEvent('li7:ready', { detail: { user, profile } }));
}

function preencherUI(profile, user) {
  if (!profile && !user) return;
  const nome = profile?.full_name || user?.email || 'Usuário';
  const inicial = nome.charAt(0).toUpperCase();
  const roles = { admin: 'Administrador', student: 'Estudante', member: 'Associado' };
  const roleLabel = roles[profile?.role] || 'Membro';

  document.querySelectorAll('[data-user-name]').forEach(el => el.textContent = nome);
  document.querySelectorAll('[data-user-role]').forEach(el => el.textContent = roleLabel);
  document.querySelectorAll('[data-user-avatar]').forEach(el => el.textContent = inicial);
  document.querySelectorAll('[data-user-email]').forEach(el => el.textContent = user?.email || '');
}

window.li7Logout = async function() {
  await supabase.auth.signOut();
  window.location.href = '/login';
}

init();
