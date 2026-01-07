-- ========================================
-- INSIGHTS FUNCTIONS
-- Run this after the main schema if the functions are missing
-- ========================================

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
    species_name TEXT,
    species_count BIGINT,
    species_percentage NUMERIC
) AS $$
DECLARE
    total_trees BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_trees FROM public.trees;

    RETURN QUERY
    SELECT
        t.species as species_name,
        COUNT(*) as species_count,
        ROUND((COUNT(*)::NUMERIC / total_trees * 100), 2) as species_percentage
    FROM public.trees t
    WHERE t.species IS NOT NULL
    GROUP BY t.species
    ORDER BY species_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
