-- ========================================
-- Tree Plantation App - Database Schema
-- ========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. USERS & AUTH TABLES
-- ========================================

-- User roles enum
CREATE TYPE user_role AS ENUM ('admin', 'volunteer', 'viewer');

-- Custom users table (links to auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role user_role NOT NULL DEFAULT 'viewer',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 2. AREAS TABLE
-- ========================================

CREATE TABLE public.areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    location_lat FLOAT8,
    location_long FLOAT8,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 3. VOLUNTEERS TABLE
-- ========================================

CREATE TABLE public.volunteers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    joined_date DATE DEFAULT CURRENT_DATE,
    total_trees_planted INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 4. TREES TABLE
-- ========================================

CREATE TYPE tree_status AS ENUM ('healthy', 'growing', 'needs_care');

CREATE TABLE public.trees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    purchase_date DATE,
    location_lat FLOAT8,
    location_long FLOAT8,
    price DECIMAL(10, 2),
    status tree_status NOT NULL DEFAULT 'healthy',
    volunteer_id UUID REFERENCES public.volunteers(id) ON DELETE SET NULL,
    area_id UUID REFERENCES public.areas(id) ON DELETE SET NULL,
    planted_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 5. PLANTATIONS TABLE
-- ========================================

CREATE TABLE public.plantations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tree_id UUID REFERENCES public.trees(id) ON DELETE CASCADE,
    volunteer_id UUID REFERENCES public.volunteers(id) ON DELETE SET NULL,
    area_id UUID REFERENCES public.areas(id) ON DELETE SET NULL,
    planted_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- INDEXES
-- ========================================

CREATE INDEX idx_trees_status ON public.trees(status);
CREATE INDEX idx_trees_volunteer ON public.trees(volunteer_id);
CREATE INDEX idx_trees_area ON public.trees(area_id);
CREATE INDEX idx_plantations_date ON public.plantations(planted_date);
CREATE INDEX idx_volunteers_active ON public.volunteers(active);

-- ========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.volunteers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plantations ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update users" ON public.users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Areas table policies
CREATE POLICY "Anyone can view areas" ON public.areas
    FOR SELECT USING (true);

CREATE POLICY "Admins and volunteers can create areas" ON public.areas
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'volunteer')
        )
    );

CREATE POLICY "Admins can update areas" ON public.areas
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete areas" ON public.areas
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Volunteers table policies
CREATE POLICY "Anyone can view volunteers" ON public.volunteers
    FOR SELECT USING (true);

CREATE POLICY "Admins can create volunteers" ON public.volunteers
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update volunteers" ON public.volunteers
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete volunteers" ON public.volunteers
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Trees table policies
CREATE POLICY "Anyone can view trees" ON public.trees
    FOR SELECT USING (true);

CREATE POLICY "Admins and volunteers can create trees" ON public.trees
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'volunteer')
        )
    );

CREATE POLICY "Admins and volunteers can update trees" ON public.trees
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'volunteer')
        )
    );

CREATE POLICY "Admins can delete trees" ON public.trees
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Plantations table policies
CREATE POLICY "Anyone can view plantations" ON public.plantations
    FOR SELECT USING (true);

CREATE POLICY "Admins and volunteers can create plantations" ON public.plantations
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'volunteer')
        )
    );

CREATE POLICY "Admins can delete plantations" ON public.plantations
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ========================================
-- FUNCTIONS & TRIGGERS
-- ========================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update_updated_at_column to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_areas_updated_at BEFORE UPDATE ON public.areas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_volunteers_updated_at BEFORE UPDATE ON public.volunteers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trees_updated_at BEFORE UPDATE ON public.trees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        COALESCE(NEW.raw_user_meta_data->>'role', 'viewer')::user_role
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ========================================
-- VIEWS FOR INSIGHTS
-- ========================================

-- Dashboard insights view
CREATE OR REPLACE VIEW public.dashboard_insights AS
SELECT
    (SELECT COUNT(*) FROM public.trees) as total_tree_count,
    (SELECT COUNT(*) FROM public.volunteers WHERE active = true) as active_volunteers,
    (SELECT COUNT(DISTINCT area_id) FROM public.trees WHERE area_id IS NOT NULL) as areas_covered,
    (SELECT COUNT(*) FROM public.trees WHERE status = 'healthy') as healthy_trees,
    (SELECT COUNT(*) FROM public.trees WHERE status = 'needs_care') as trees_needing_care;

-- Function to get monthly plantation progress
CREATE OR REPLACE FUNCTION public.get_monthly_plantation_progress()
RETURNS TABLE (
    month TEXT,
    trees_planted BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(planted_date, 'Mon YYYY') as month,
        COUNT(*) as trees_planted
    FROM public.plantations
    WHERE planted_date IS NOT NULL
    GROUP BY TO_CHAR(planted_date, 'Mon YYYY'), DATE_TRUNC('month', planted_date)
    ORDER BY DATE_TRUNC('month', planted_date) DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get species distribution
CREATE OR REPLACE FUNCTION public.get_species_distribution()
RETURNS TABLE (
    species TEXT,
    count BIGINT,
    percentage NUMERIC
) AS $$
DECLARE
    total_trees BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_trees FROM public.trees;

    RETURN QUERY
    SELECT
        species,
        COUNT(*) as count,
        ROUND((COUNT(*)::NUMERIC / total_trees * 100), 2) as percentage
    FROM public.trees
    WHERE species IS NOT NULL
    GROUP BY species
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- SEED DATA
-- ========================================

-- Insert seed areas
INSERT INTO public.areas (name, description, location_lat, location_long) VALUES
('Central Park', 'Main plantation area in city center', 40.7829, -73.9654),
('River Side', 'Plantation along the river bank', 40.7580, -73.9855),
('Hilltop Garden', 'Elevated garden area', 40.7736, -73.9712);

-- Insert seed volunteers
INSERT INTO public.volunteers (name, email, phone, joined_date, total_trees_planted, active) VALUES
('John Smith', 'john.smith@example.com', '+1-555-0101', '2024-01-15', 25, true),
('Sarah Johnson', 'sarah.j@example.com', '+1-555-0102', '2024-02-01', 30, true),
('Mike Davis', 'mike.davis@example.com', '+1-555-0103', '2024-03-10', 18, true),
('Emily Brown', 'emily.b@example.com', '+1-555-0104', '2024-04-05', 22, false);

-- Insert seed trees
INSERT INTO public.trees (name, species, purchase_date, location_lat, location_long, price, status, volunteer_id, area_id, planted_date) VALUES
('Oak Tree 1', 'Quercus robur', '2024-01-20', 40.7829, -73.9654, 150.00, 'healthy',
 (SELECT id FROM public.volunteers WHERE name = 'John Smith'),
 (SELECT id FROM public.areas WHERE name = 'Central Park'), '2024-01-25'),
('Maple Tree 1', 'Acer saccharum', '2024-02-10', 40.7830, -73.9655, 120.00, 'healthy',
 (SELECT id FROM public.volunteers WHERE name = 'Sarah Johnson'),
 (SELECT id FROM public.areas WHERE name = 'Central Park'), '2024-02-15'),
('Pine Tree 1', 'Pinus strobus', '2024-03-15', 40.7580, -73.9855, 95.00, 'growing',
 (SELECT id FROM public.volunteers WHERE name = 'Mike Davis'),
 (SELECT id FROM public.areas WHERE name = 'River Side'), '2024-03-20'),
('Birch Tree 1', 'Betula pendula', '2024-04-01', 40.7736, -73.9712, 110.00, 'needs_care',
 (SELECT id FROM public.volunteers WHERE name = 'Emily Brown'),
 (SELECT id FROM public.areas WHERE name = 'Hilltop Garden'), '2024-04-05'),
('Oak Tree 2', 'Quercus alba', '2024-04-20', 40.7831, -73.9656, 160.00, 'healthy',
 (SELECT id FROM public.volunteers WHERE name = 'John Smith'),
 (SELECT id FROM public.areas WHERE name = 'Central Park'), '2024-04-25'),
('Maple Tree 2', 'Acer rubrum', '2024-05-10', 40.7581, -73.9856, 130.00, 'growing',
 (SELECT id FROM public.volunteers WHERE name = 'Sarah Johnson'),
 (SELECT id FROM public.areas WHERE name = 'River Side'), '2024-05-15'),
('Willow Tree 1', 'Salix babylonica', '2024-05-25', 40.7737, -73.9713, 140.00, 'healthy',
 (SELECT id FROM public.volunteers WHERE name = 'Mike Davis'),
 (SELECT id FROM public.areas WHERE name = 'Hilltop Garden'), '2024-05-30'),
('Cherry Tree 1', 'Prunus avium', '2024-06-01', 40.7832, -73.9657, 175.00, 'healthy',
 (SELECT id FROM public.volunteers WHERE name = 'John Smith'),
 (SELECT id FROM public.areas WHERE name = 'Central Park'), '2024-06-05');

-- Insert seed plantations
INSERT INTO public.plantations (tree_id, volunteer_id, area_id, planted_date, notes)
SELECT 
    t.id,
    t.volunteer_id,
    t.area_id,
    t.planted_date,
    'Initial planting for ' || t.species
FROM public.trees t
WHERE t.planted_date IS NOT NULL;
