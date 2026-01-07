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
