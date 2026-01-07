<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { onMount } from 'svelte';

	interface MonthlyProgress {
		month: string;
		trees_planted: number;
	}

	interface SpeciesDistribution {
		species: string;
		count: number;
		percentage: number;
	}

	interface VolunteerContribution {
		name: string;
		total_trees_planted: number;
	}

	let monthlyProgress = $state<MonthlyProgress[]>([]);
	let speciesDistribution = $state<SpeciesDistribution[]>([]);
	let volunteerContributions = $state<VolunteerContribution[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	async function loadInsights() {
		try {
			loading = true;
			error = null;

			const monthlyResult = await supabase.rpc('get_monthly_plantation_progress');
			if (monthlyResult.error) {
				console.error('Monthly progress error:', monthlyResult.error);
				throw new Error(`Failed to load monthly progress: ${monthlyResult.error.message}`);
			}
			monthlyProgress = monthlyResult.data || [];

			const speciesResult = await supabase.rpc('get_species_distribution');
			if (speciesResult.error) {
				console.error('Species distribution error:', speciesResult.error);
				throw new Error(`Failed to load species distribution: ${speciesResult.error.message}`);
			}
			speciesDistribution = speciesResult.data || [];

			const volunteerResult = await supabase
				.from('volunteers')
				.select('name, total_trees_planted')
				.order('total_trees_planted', { ascending: false })
				.limit(10);

			if (volunteerResult.error) {
				console.error('Volunteer contributions error:', volunteerResult.error);
				throw new Error(`Failed to load volunteer contributions: ${volunteerResult.error.message}`);
			}
			volunteerContributions = volunteerResult.data || [];
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load insights';
			console.error('Error loading insights:', err);
		} finally {
			loading = false;
		}
	}

	onMount(() => {
		loadInsights();
	});

	function getSpeciesColor(species: string): string {
		const colors = [
			'#4CAF50',
			'#2196F3',
			'#FF9800',
			'#9C27B0',
			'#F44336',
			'#00BCD4',
			'#8BC34A',
			'#FFEB3B',
			'#795548',
			'#607D8B'
		];
		const hash = species.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
		return colors[hash % colors.length];
	}

	function getCumulativePercentage(index: number, data: SpeciesDistribution[]): number {
		return data.slice(0, index).reduce((sum, item) => sum + item.percentage, 0) * 3.6;
	}

	function getPieCoordinates(index: number, data: SpeciesDistribution[]): string {
		const percentage = data[index].percentage;
		const startAngle = (getCumulativePercentage(index, data) * Math.PI) / 180;
		const endAngle = startAngle + (percentage * 3.6 * Math.PI) / 180;

		const x1 = 50 + 40 * Math.cos(startAngle);
		const y1 = 50 + 40 * Math.sin(startAngle);
		const x2 = 50 + 40 * Math.cos(endAngle);
		const y2 = 50 + 40 * Math.sin(endAngle);

		return `${x1}% ${y1}%, ${x2}% ${y2}%`;
	}
</script>

<div class="container">
	<h1 class="page-title">Contribution Insights</h1>

	{#if loading}
		<div class="loading">Loading insights...</div>
	{:else if error}
		<div class="error">
			<p>{error}</p>
			{#if error.includes('function') || error.includes('get_monthly') || error.includes('get_species')}
				<p class="error-hint">
					<strong>Note:</strong> Make sure you have run the SQL functions from
					<code>supabase-insights-functions.sql</code> in your Supabase SQL Editor.
				</p>
			{/if}
		</div>
	{:else}
		<div class="insights-grid">
			<section class="insight-card">
				<h2>Monthly Plantation Progress</h2>
				{#if monthlyProgress.length > 0}
					<div class="bar-chart">
						{#each monthlyProgress as item}
							<div class="bar-item">
								<div class="bar-label">{item.month}</div>
								<div class="bar-container">
									<div
										class="bar"
										style="width: {(item.trees_planted / Math.max(...monthlyProgress.map((p) => p.trees_planted))) * 100}%"
									></div>
								</div>
								<div class="bar-value">{item.trees_planted}</div>
							</div>
						{/each}
					</div>
				{:else}
					<p class="no-data">No data available</p>
				{/if}
			</section>

			<section class="insight-card">
				<h2>Species Distribution</h2>
				{#if speciesDistribution.length > 0}
					<div class="pie-legend">
						{#each speciesDistribution as item}
							<div class="legend-item">
								<div class="legend-color" style="background-color: {getSpeciesColor(item.species)}"></div>
								<div class="legend-text">
									<span class="legend-label">{item.species}</span>
									<span class="legend-value">{item.count} ({item.percentage.toFixed(1)}%)</span>
								</div>
							</div>
						{/each}
					</div>
					<div class="pie-chart">
						{#each speciesDistribution as item, index}
							<div
								class="pie-segment"
								style="
									background-color: {getSpeciesColor(item.species)};
									transform: rotate({getCumulativePercentage(index, speciesDistribution)}deg);
									clip-path: polygon(50% 50%, {getPieCoordinates(index, speciesDistribution)})
								"
							></div>
						{/each}
					</div>
				{:else}
					<p class="no-data">No data available</p>
				{/if}
			</section>

			<section class="insight-card full-width">
				<h2>Volunteer Contributions</h2>
				{#if volunteerContributions.length > 0}
					<div class="volunteer-list">
						{#each volunteerContributions as volunteer}
							<div class="volunteer-item">
								<div class="volunteer-info">
									<span class="volunteer-rank">#{volunteerContributions.indexOf(volunteer) + 1}</span>
									<span class="volunteer-name">{volunteer.name}</span>
								</div>
								<div class="volunteer-trees">
									<span class="tree-count">{volunteer.total_trees_planted}</span>
									<span class="tree-label">trees</span>
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<p class="no-data">No data available</p>
				{/if}
			</section>
		</div>
	{/if}
</div>

<style>
	.container {
		max-width: 1400px;
		margin: 0 auto;
		padding: 2rem;
	}

	.page-title {
		color: #2c5f2d;
		margin-bottom: 2rem;
		text-align: center;
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

	.error p {
		margin: 0.5rem 0;
	}

	.error-hint {
		font-size: 0.9rem;
		color: #666;
		margin-top: 1rem !important;
		padding-top: 1rem;
		border-top: 1px solid #fcc;
	}

	.error-hint code {
		background-color: #f5f5f5;
		padding: 0.2rem 0.4rem;
		border-radius: 3px;
		font-family: monospace;
		color: #d32f2f;
	}

	.insights-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
		gap: 2rem;
		margin-top: 2rem;
	}

	.insight-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	}

	.insight-card.full-width {
		grid-column: 1 / -1;
	}

	.insight-card h2 {
		color: #2c5f2d;
		margin: 0 0 1.5rem 0;
		font-size: 1.5rem;
	}

	.no-data {
		text-align: center;
		color: #999;
		font-style: italic;
	}

	.bar-chart {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.bar-item {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.bar-label {
		min-width: 100px;
		font-size: 0.85rem;
		color: #666;
	}

	.bar-container {
		flex: 1;
		height: 24px;
		background-color: #f5f5f5;
		border-radius: 4px;
		overflow: hidden;
	}

	.bar {
		height: 100%;
		background-color: #4CAF50;
		transition: width 0.3s ease;
	}

	.bar-value {
		min-width: 40px;
		text-align: right;
		font-weight: 600;
		color: #333;
	}

	.pie-legend {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		margin-bottom: 1rem;
	}

	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.legend-color {
		width: 16px;
		height: 16px;
		border-radius: 4px;
	}

	.legend-text {
		flex: 1;
		display: flex;
		justify-content: space-between;
	}

	.legend-label {
		color: #333;
	}

	.legend-value {
		color: #666;
		font-weight: 500;
	}

	.pie-chart {
		width: 200px;
		height: 200px;
		border-radius: 50%;
		position: relative;
		margin: 0 auto;
	}

	.pie-segment {
		position: absolute;
		width: 100%;
		height: 100%;
		border-radius: 50%;
		transition: transform 0.3s ease;
	}

	.pie-segment:hover {
		transform: scale(1.05) !important;
	}

	.volunteer-list {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.volunteer-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1rem;
		background-color: #f9f9f9;
		border-radius: 8px;
		border-left: 4px solid #2c5f2d;
	}

	.volunteer-info {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.volunteer-rank {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 32px;
		height: 32px;
		background-color: #2c5f2d;
		color: white;
		border-radius: 50%;
		font-weight: bold;
		font-size: 0.9rem;
	}

	.volunteer-name {
		font-weight: 500;
		color: #333;
	}

	.volunteer-trees {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.tree-count {
		font-size: 1.5rem;
		font-weight: bold;
		color: #4CAF50;
	}

	.tree-label {
		color: #666;
		font-size: 0.85rem;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}
</style>
