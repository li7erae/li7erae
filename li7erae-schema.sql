-- =============================================
--  LI7ERAE — BANCO DE DADOS SUPABASE
--  Cole TODO esse código no SQL Editor
--  e clique em RUN (▶)
-- =============================================

-- TABELA: Perfis de usuário
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'student',
  plan TEXT DEFAULT 'essential',
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: Cursos
CREATE TABLE IF NOT EXISTS courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  price DECIMAL(10,2) DEFAULT 0,
  is_free BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'draft',
  thumbnail_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: Aulas (com YouTube!)
CREATE TABLE IF NOT EXISTS lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  youtube_url TEXT,
  youtube_id TEXT,
  duration_minutes INTEGER DEFAULT 0,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: Matrículas
CREATE TABLE IF NOT EXISTS enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  course_id UUID REFERENCES courses(id),
  progress_percent INTEGER DEFAULT 0,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- TABELA: Certificados
CREATE TABLE IF NOT EXISTS certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  course_id UUID REFERENCES courses(id),
  certificate_code TEXT UNIQUE DEFAULT gen_random_uuid()::TEXT,
  issued_at TIMESTAMPTZ DEFAULT NOW()
);

-- TABELA: Solidariedade
CREATE TABLE IF NOT EXISTS solidarity (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
--  SEGURANÇA (RLS)
-- =============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Perfis visíveis" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Usuário vê seu perfil" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Cursos publicados visíveis" ON courses
  FOR SELECT USING (status = 'published');

CREATE POLICY "Usuário vê suas matrículas" ON enrollments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuário vê seus certificados" ON certificates
  FOR SELECT USING (auth.uid() = user_id);

-- =============================================
--  PRONTO! Deve aparecer "Success" abaixo ✅
-- =============================================
