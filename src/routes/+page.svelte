<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseClient';

	interface DashboardStats {
		total_tree_count: number;
		active_volunteers: number;
		areas_covered: number;
		healthy_trees: number;
		trees_needing_care: number;
	}

	let stats = $state<DashboardStats | null>(null);
	let loading = $state(true);
	let error = $state<string | null>(null);

	async function loadStats() {
		try {
			loading = true;
			const { data, error: fetchError } = await supabase
				.from('dashboard_insights')
				.select('*')
				.single();

			if (fetchError) throw fetchError;

			stats = data;
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load dashboard data';
			console.error('Error loading dashboard stats:', err);
		} finally {
			loading = false;
		}
	}

	onMount(() => {
		loadStats();
	});
</script>

<div class="container">
	<h1 class="welcome-message">Welcome to Folium Tree Plantation Dashboard</h1>

	{#if loading}
		<div class="loading">Loading dashboard data...</div>
	{:else if error}
		<div class="error">{error}</div>
	{:else if stats}
		<div class="stats-grid">
			<div class="stat-card trees">
				<div class="stat-icon">🌳</div>
				<div class="stat-content">
					<h2>Total Trees</h2>
					<p class="stat-number">{stats.total_tree_count}</p>
				</div>
			</div>

			<div class="stat-card volunteers">
				<div class="stat-icon">👥</div>
				<div class="stat-content">
					<h2>Active Volunteers</h2>
					<p class="stat-number">{stats.active_volunteers}</p>
				</div>
			</div>

			<div class="stat-card areas">
				<div class="stat-icon">🗺️</div>
				<div class="stat-content">
					<h2>Areas Covered</h2>
					<p class="stat-number">{stats.areas_covered}</p>
				</div>
			</div>

			<div class="stat-card healthy">
				<div class="stat-icon">✅</div>
				<div class="stat-content">
					<h2>Healthy Trees</h2>
					<p class="stat-number">{stats.healthy_trees}</p>
				</div>
			</div>

			<div class="stat-card needs-care">
				<div class="stat-icon">⚠️</div>
				<div class="stat-content">
					<h2>Trees Needing Care</h2>
					<p class="stat-number">{stats.trees_needing_care}</p>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 2rem;
	}

	.welcome-message {
		text-align: center;
		color: #2c5f2d;
		margin-bottom: 3rem;
		font-size: 2.5rem;
	}

	.loading {
		text-align: center;
		font-size: 1.2rem;
		color: #666;
		margin: 2rem 0;
	}

	.error {
		background-color: #fee;
		border: 1px solid #fcc;
		color: #c33;
		padding: 1rem;
		border-radius: 4px;
		text-align: center;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 1.5rem;
		margin-top: 2rem;
	}

	.stat-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		display: flex;
		align-items: center;
		gap: 1rem;
		transition: transform 0.2s ease, box-shadow 0.2s ease;
	}

	.stat-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
	}

	.stat-card.trees {
		border-left: 4px solid #4CAF50;
	}

	.stat-card.volunteers {
		border-left: 4px solid #2196F3;
	}

	.stat-card.areas {
		border-left: 4px solid #FF9800;
	}

	.stat-card.healthy {
		border-left: 4px solid #8BC34A;
	}

	.stat-card.needs-care {
		border-left: 4px solid #f44336;
	}

	.stat-icon {
		font-size: 3rem;
		display: flex;
		align-items: center;
		justify-content: center;
		min-width: 60px;
	}

	.stat-content h2 {
		margin: 0 0 0.5rem 0;
		font-size: 0.9rem;
		color: #666;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.stat-number {
		margin: 0;
		font-size: 2.5rem;
		font-weight: bold;
		color: #333;
	}
</style>
