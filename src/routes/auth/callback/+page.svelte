<script lang="ts">
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseClient';
	import { goto } from '$app/navigation';

	onMount(async () => {
		try {
			const { data, error } = await supabase.auth.getSession();

			if (error) throw error;

			if (data.session) {
				goto('/');
			} else {
				goto('/signin');
			}
		} catch (err) {
			console.error('Auth callback error:', err);
			goto('/signin');
		}
	});
</script>

<div class="callback-container">
	<div class="loading-spinner">
		<div class="spinner"></div>
		<p>Completing authentication...</p>
	</div>
</div>

<style>
	.callback-container {
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		background: var(--background-color);
	}

	.loading-spinner {
		text-align: center;
	}

	.spinner {
		width: 50px;
		height: 50px;
		border: 4px solid #f3f3f3;
		border-top: 4px solid var(--primary-color);
		border-radius: 50%;
		animation: spin 1s linear infinite;
		margin: 0 auto 1.5rem;
	}

	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
</style>
