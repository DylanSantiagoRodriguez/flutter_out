-- ==========================================================
-- SMARTCOOK DATABASE SCHEMA
-- Author: Dylan (KlauZ)
-- Platform: Supabase (PostgreSQL 15)
-- ==========================================================

-- =======================
-- 1. USERS
-- =======================
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100),
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =======================
-- 2. UPLOADS
-- =======================
CREATE TABLE public.uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    image_url TEXT,
    text_input TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =======================
-- 3. INGREDIENTS
-- =======================
CREATE TABLE public.ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    upload_id UUID REFERENCES public.uploads(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    confidence FLOAT,
    source VARCHAR(20) CHECK (source IN ('text', 'image')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =======================
-- 4. RECIPES
-- =======================
CREATE TABLE public.recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    upload_id UUID REFERENCES public.uploads(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    ingredients_list JSONB,
    steps JSONB,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =======================
-- 5. SAVED_RECIPES
-- =======================
CREATE TABLE public.saved_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, recipe_id)  -- evita duplicados en recetas guardadas
);

-- =======================
-- 6. (Opcional) SESSIONS
-- =======================
CREATE TABLE public.sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    response TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =======================
-- INDEXES
-- =======================
CREATE INDEX idx_uploads_user_id ON public.uploads(user_id);
CREATE INDEX idx_ingredients_upload_id ON public.ingredients(upload_id);
CREATE INDEX idx_recipes_upload_id ON public.recipes(upload_id);
CREATE INDEX idx_saved_recipes_user_id ON public.saved_recipes(user_id);
CREATE INDEX idx_saved_recipes_recipe_id ON public.saved_recipes(recipe_id);

-- =======================
-- SECURITY POLICIES (Supabase RLS)
-- =======================
-- Nota: habilita RLS (Row Level Security) si usas autenticación Supabase Auth
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

-- Ejemplo de política básica para que cada usuario vea solo sus datos
CREATE POLICY "Users can view their own uploads"
  ON public.uploads
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own uploads"
  ON public.uploads
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view recipes public or own"
  ON public.recipes
  FOR SELECT USING (
    upload_id IS NULL
    OR EXISTS (
      SELECT 1 FROM public.uploads up
      WHERE up.id = upload_id AND up.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert recipes public or own"
  ON public.recipes
  FOR INSERT WITH CHECK (
    upload_id IS NULL
    OR EXISTS (
      SELECT 1 FROM public.uploads up
      WHERE up.id = upload_id AND up.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view their own saved recipes"
  ON public.saved_recipes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own saved recipes"
  ON public.saved_recipes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own saved recipes"
  ON public.saved_recipes
  FOR DELETE USING (auth.uid() = user_id);

-- =======================
-- VIEWS (Opcional)
-- =======================
-- Vista para mostrar el historial completo de un usuario con sus recetas
CREATE VIEW public.user_recipe_history AS
SELECT 
    u.id AS user_id,
    u.name AS user_name,
    r.id AS recipe_id,
    r.title,
    r.description,
    r.created_at AS recipe_date,
    up.text_input AS ingredients_input,
    up.image_url AS uploaded_image
FROM public.users u
JOIN public.uploads up ON up.user_id = u.id
JOIN public.recipes r ON r.upload_id = up.id
ORDER BY r.created_at DESC;

-- ==========================================================
-- END OF SMARTCOOK SCHEMA
-- ==========================================================
 