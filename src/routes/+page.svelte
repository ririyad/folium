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

<div class="dashboard-header">
	<div class="container">
		<div class="header-content">
			<h1>Dashboard</h1>
			<p>Overview of your plantation activities and impact</p>
		</div>
	</div>
</div>

<div class="container negative-margin">
	{#if loading}
		<div class="loading-state">
			<div class="spinner"></div>
			<p>Loading dashboard data...</p>
		</div>
	{:else if error}
		<div class="error-state">
			<span class="error-icon">⚠️</span>
			<p>{error}</p>
			<button class="btn btn-primary" onclick={() => loadStats()}>Try Again</button>
		</div>
	{:else if stats}
		<div class="stats-grid">
			<div class="stat-card primary">
				<div class="stat-icon">🌳</div>
				<div class="stat-content">
					<p class="stat-label">Total Trees</p>
					<p class="stat-number">{stats.total_tree_count}</p>
				</div>
				<div class="stat-trend">
					<span>↗ +12%</span> since last month
				</div>
			</div>

			<div class="stat-card info">
				<div class="stat-icon">👥</div>
				<div class="stat-content">
					<p class="stat-label">Active Volunteers</p>
					<p class="stat-number">{stats.active_volunteers}</p>
				</div>
				<div class="stat-trend">
					<span>↗ +5</span> new this week
				</div>
			</div>

			<div class="stat-card accent">
				<div class="stat-icon">🗺️</div>
				<div class="stat-content">
					<p class="stat-label">Areas Covered</p>
					<p class="stat-number">{stats.areas_covered}</p>
				</div>
				<div class="stat-trend neutral">
					<span>=</span> same as last month
				</div>
			</div>
		</div>

		<div class="health-section">
			<h2>Health Status</h2>
			<div class="health-grid">
				<div class="health-card healthy">
					<div class="health-header">
						<span class="icon">✅</span>
						<h3>Healthy</h3>
					</div>
					<div class="health-value">{stats.healthy_trees}</div>
					<div class="health-bar">
						<div class="bar-fill" style="width: {(stats.healthy_trees / stats.total_tree_count) * 100}%"></div>
					</div>
				</div>

				<div class="health-card warning">
					<div class="health-header">
						<span class="icon">⚠️</span>
						<h3>Needs Care</h3>
					</div>
					<div class="health-value">{stats.trees_needing_care}</div>
					<div class="health-bar">
						<div class="bar-fill" style="width: {(stats.trees_needing_care / stats.total_tree_count) * 100}%"></div>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>

<style>
	.dashboard-header {
		background-color: var(--primary-color);
		color: white;
		padding: 4rem 0 8rem;
		background-image: linear-gradient(rgba(44, 95, 45, 0.9), rgba(44, 95, 45, 0.95)), url('https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&q=80');
		background-size: cover;
		background-position: center;
	}

	.header-content h1 {
		color: white;
		font-size: 2.5rem;
		margin-bottom: 0.5rem;
	}

	.header-content p {
		font-size: 1.1rem;
		opacity: 0.9;
		margin: 0;
	}

	.negative-margin {
		margin-top: -4rem;
		position: relative;
		z-index: 10;
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 2rem;
		margin-bottom: 3rem;
	}

	.stat-card {
		background: white;
		border-radius: 16px;
		padding: 1.5rem;
		box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
		transition: transform 0.3s ease;
		border: 1px solid rgba(0,0,0,0.05);
	}

	.stat-card:hover {
		transform: translateY(-5px);
	}

	.stat-icon {
		font-size: 2.5rem;
		margin-bottom: 1rem;
		background: #f8fafc;
		width: 60px;
		height: 60px;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 12px;
	}

	.stat-label {
		color: var(--text-secondary);
		font-size: 0.9rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		margin: 0 0 0.25rem 0;
	}

	.stat-number {
		color: var(--text-primary);
		font-size: 2.5rem;
		font-weight: 800;
		margin: 0 0 1rem 0;
		line-height: 1;
	}

	.stat-trend {
		font-size: 0.85rem;
		color: var(--success);
		font-weight: 500;
		display: flex;
		align-items: center;
		gap: 0.25rem;
	}

	.stat-trend.neutral {
		color: var(--text-secondary);
	}

	.health-section {
		background: white;
		border-radius: 16px;
		padding: 2rem;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
	}

	.health-section h2 {
		margin-bottom: 2rem;
		font-size: 1.5rem;
	}

	.health-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
		gap: 2rem;
	}

	.health-card {
		padding: 1.5rem;
		border-radius: 12px;
		background: #f8fafc;
		border: 1px solid #e2e8f0;
	}

	.health-header {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin-bottom: 1rem;
	}

	.health-header h3 {
		margin: 0;
		font-size: 1.1rem;
		color: var(--text-primary);
	}

	.health-value {
		font-size: 2rem;
		font-weight: 700;
		margin-bottom: 1rem;
	}

	.health-bar {
		height: 8px;
		background: #e2e8f0;
		border-radius: 4px;
		overflow: hidden;
	}

	.bar-fill {
		height: 100%;
		border-radius: 4px;
		transition: width 1s ease-out;
	}

	.health-card.healthy .bar-fill {
		background-color: var(--success);
	}

	.health-card.warning .bar-fill {
		background-color: var(--warning);
	}

	.loading-state {
		text-align: center;
		padding: 4rem;
		background: white;
		border-radius: 16px;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
	}

	.spinner {
		border: 4px solid #f3f3f3;
		border-top: 4px solid var(--primary-color);
		border-radius: 50%;
		width: 40px;
		height: 40px;
		animation: spin 1s linear infinite;
		margin: 0 auto 1rem;
	}

	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
</style>
