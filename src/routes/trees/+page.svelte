<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { onMount } from 'svelte';

	type UserRole = 'admin' | 'volunteer' | 'viewer';

	interface Tree {
		id: string;
		name: string;
		species: string;
		purchase_date: string | null;
		location_lat: number | null;
		location_long: number | null;
		price: number | null;
		status: 'healthy' | 'growing' | 'needs_care';
	}

	let trees = $state<Tree[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);
	let showForm = $state(false);
	let editingTree = $state<Tree | null>(null);
	let user = $state<any>(null);
	let userRole = $state<UserRole | null>(null);
	let canEdit = $state(false);

	let formData = $state({
		name: '',
		species: '',
		purchase_date: '',
		location_lat: '',
		location_long: '',
		price: '',
		status: 'healthy' as Tree['status']
	});

	async function loadUser() {
		try {
			const { data: { session } } = await supabase.auth.getSession();
			if (!session?.user) {
				userRole = 'viewer';
				return;
			}

			user = session.user;

			const { data: userData, error: userError } = await supabase
				.from('users')
				.select('role')
				.eq('id', session.user.id)
				.single();

			if (userError) {
				console.error('Error fetching user role:', userError);
				userRole = 'viewer';
				return;
			}

			userRole = userData?.role || 'viewer';
			canEdit = userRole === 'admin' || userRole === 'volunteer';
		} catch (err) {
			console.error('Error loading user:', err);
			userRole = 'viewer';
		}
	}

	async function loadTrees() {
		try {
			loading = true;
			const { data, error: fetchError } = await supabase
				.from('trees')
				.select('*')
				.order('created_at', { ascending: false });

			if (fetchError) throw fetchError;
			trees = data || [];
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to load trees';
			console.error('Error loading trees:', err);
		} finally {
			loading = false;
		}
	}

	function openForm(tree?: Tree) {
		if (!canEdit) return;

		if (tree) {
			editingTree = tree;
			formData = {
				name: tree.name,
				species: tree.species,
				purchase_date: tree.purchase_date || '',
				location_lat: tree.location_lat?.toString() || '',
				location_long: tree.location_long?.toString() || '',
				price: tree.price?.toString() || '',
				status: tree.status
			};
		} else {
			editingTree = null;
			formData = {
				name: '',
				species: '',
				purchase_date: '',
				location_lat: '',
				location_long: '',
				price: '',
				status: 'healthy'
			};
		}
		showForm = true;
	}

	function closeForm() {
		showForm = false;
		editingTree = null;
	}

	async function saveTree() {
		try {
			const treeData = {
				name: formData.name,
				species: formData.species,
				purchase_date: formData.purchase_date || null,
				location_lat: formData.location_lat ? parseFloat(formData.location_lat) : null,
				location_long: formData.location_long ? parseFloat(formData.location_long) : null,
				price: formData.price ? parseFloat(formData.price) : null,
				status: formData.status
			};

			if (editingTree) {
				const { error } = await supabase
					.from('trees')
					.update(treeData)
					.eq('id', editingTree.id);

				if (error) throw error;
			} else {
				const { error } = await supabase.from('trees').insert([treeData]);

				if (error) throw error;
			}

			closeForm();
			await loadTrees();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to save tree';
			console.error('Error saving tree:', err);
		}
	}

	async function deleteTree(id: string) {
		if (!canEdit) return;

		if (!confirm('Are you sure you want to delete this tree?')) return;

		try {
			const { error } = await supabase.from('trees').delete().eq('id', id);

			if (error) throw error;
			await loadTrees();
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to delete tree';
			console.error('Error deleting tree:', err);
		}
	}

	function getStatusColor(status: Tree['status']) {
		switch (status) {
			case 'healthy':
				return '#4CAF50';
			case 'growing':
				return '#2196F3';
			case 'needs_care':
				return '#f44336';
			default:
				return '#666';
		}
	}

	onMount(() => {
		loadUser();
		loadTrees();
	});

</script>

<div class="container">
	<div class="header">
		<h1>Tree Management</h1>
		{#if userRole === 'admin' || userRole === 'volunteer'}
			<button class="btn btn-primary" onclick={() => openForm()}>
				+ Add New Tree
			</button>
		{:else}
			<div class="permission-hint">
				<span class="icon">🔒</span>
				<span>Only Admin and Volunteer roles can add trees</span>
			</div>
		{/if}
	</div>

	{#if loading}
		<div class="loading">Loading trees...</div>
	{:else if error}
		<div class="error">{error}</div>
	{:else}
		<div class="tree-grid">
			{#each trees as tree (tree.id)}
				<div class="tree-card">
					<div class="tree-header">
						<h2>{tree.name}</h2>
						<span class="status-badge" style="background-color: {getStatusColor(tree.status)}">
							{tree.status.replace('_', ' ')}
						</span>
					</div>
					<div class="tree-details">
						<p><strong>Species:</strong> {tree.species}</p>
						{#if tree.purchase_date}
							<p><strong>Purchase Date:</strong> {new Date(tree.purchase_date).toLocaleDateString()}</p>
						{/if}
						{#if tree.price}
							<p><strong>Price:</strong> ৳{tree.price.toFixed(2)}</p>
						{/if}
						{#if tree.location_lat && tree.location_long}
							<p><strong>Location:</strong> {tree.location_lat.toFixed(4)}, {tree.location_long.toFixed(4)}</p>
						{/if}
					</div>
					<div class="tree-actions">
						<button class="btn btn-secondary" on:click={() => openForm(tree)}>Edit</button>
						<button class="btn btn-danger" on:click={() => deleteTree(tree.id)}>Delete</button>
					</div>
				</div>
			{/each}
		</div>
	{/if}
</div>

{#if showForm}
	<div class="modal-overlay" on:click={closeForm}>
		<div class="modal" on:click|stopPropagation>
			<h2>{editingTree ? 'Edit Tree' : 'Add New Tree'}</h2>
			<form on:submit|preventDefault={saveTree}>
				<div class="form-group">
					<label for="name">Name *</label>
					<input
						id="name"
						type="text"
						bind:value={formData.name}
						required
						placeholder="Enter tree name"
					/>
				</div>
				<div class="form-group">
					<label for="species">Species *</label>
					<input
						id="species"
						type="text"
						bind:value={formData.species}
						required
						placeholder="Enter tree species"
					/>
				</div>
				<div class="form-group">
					<label for="purchase_date">Purchase Date</label>
					<input id="purchase_date" type="date" bind:value={formData.purchase_date} />
				</div>
				<div class="form-group">
					<label for="location_lat">Latitude</label>
					<input
						id="location_lat"
						type="number"
						step="any"
						bind:value={formData.location_lat}
						placeholder="e.g., 40.7829"
					/>
				</div>
				<div class="form-group">
					<label for="location_long">Longitude</label>
					<input
						id="location_long"
						type="number"
						step="any"
						bind:value={formData.location_long}
						placeholder="e.g., -73.9654"
					/>
				</div>
				<div class="form-group">
					<label for="price">Price (BDT)</label>
					<input
						id="price"
						type="number"
						step="0.01"
						bind:value={formData.price}
						placeholder="e.g., 150.00"
					/>
				</div>
				<div class="form-group">
					<label for="status">Status</label>
					<select id="status" bind:value={formData.status}>
						<option value="healthy">Healthy</option>
						<option value="growing">Growing</option>
						<option value="needs_care">Needs Care</option>
					</select>
				</div>
				<div class="form-actions">
					<button type="button" class="btn btn-secondary" on:click={closeForm}>Cancel</button>
					<button type="submit" class="btn btn-primary">
						{editingTree ? 'Update' : 'Create'} Tree
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 2rem;
	}

	.header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
	}

	.header h1 {
		color: #2c5f2d;
		margin: 0;
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

	.tree-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1.5rem;
	}

	.tree-card {
		background: white;
		border-radius: 12px;
		padding: 1.5rem;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		transition: transform 0.2s ease, box-shadow 0.2s ease;
	}

	.tree-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
	}

	.tree-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		margin-bottom: 1rem;
	}

	.tree-header h2 {
		margin: 0;
		color: #333;
		font-size: 1.25rem;
	}

	.status-badge {
		color: white;
		padding: 0.25rem 0.75rem;
		border-radius: 12px;
		font-size: 0.75rem;
		font-weight: 500;
		text-transform: uppercase;
	}

	.tree-details {
		margin-bottom: 1.5rem;
	}

	.tree-details p {
		margin: 0.5rem 0;
		color: #666;
		font-size: 0.9rem;
	}

	.tree-actions {
		display: flex;
		gap: 0.5rem;
	}

	.btn {
		padding: 0.5rem 1rem;
		border: none;
		border-radius: 4px;
		cursor: pointer;
		font-weight: 500;
		transition: background-color 0.2s ease;
	}

	.btn-primary {
		background-color: #2c5f2d;
		color: white;
	}

	.btn-primary:hover {
		background-color: #1e421f;
	}

	.btn-secondary {
		background-color: #666;
		color: white;
	}

	.btn-secondary:hover {
		background-color: #555;
	}

	.btn-danger {
		background-color: #f44336;
		color: white;
	}

	.btn-danger:hover {
		background-color: #da190b;
	}

	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background-color: rgba(0, 0, 0, 0.5);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 1000;
	}

	.modal {
		background: white;
		border-radius: 12px;
		padding: 2rem;
		max-width: 500px;
		width: 100%;
		max-height: 90vh;
		overflow-y: auto;
	}

	.modal h2 {
		margin: 0 0 1.5rem 0;
		color: #2c5f2d;
	}

	.form-group {
		margin-bottom: 1rem;
	}

	.form-group label {
		display: block;
		margin-bottom: 0.5rem;
		color: #333;
		font-weight: 500;
	}

	.form-group input,
	.form-group select {
		width: 100%;
		padding: 0.5rem;
		border: 1px solid #ddd;
		border-radius: 4px;
		font-size: 1rem;
	}

	.form-group input:focus,
	.form-group select:focus {
		outline: none;
		border-color: #2c5f2d;
	}

	.form-actions {
		display: flex;
		justify-content: flex-end;
		gap: 0.5rem;
		margin-top: 1.5rem;
	}
</style>
