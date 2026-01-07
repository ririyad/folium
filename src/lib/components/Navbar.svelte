<script lang="ts">
	import { page } from '$app/stores';
	import { supabase } from '$lib/supabaseClient';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	let user = $state(null);

	async function signOut() {
		await supabase.auth.signOut();
		goto('/signin');
	}

	onMount(() => {
		supabase.auth.getSession().then(({ data: { session } }) => {
			user = session?.user;
		});

		const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
			user = session?.user;
		});
	});
</script>

<nav class="navbar">
	<div class="nav-container">
		<a href="/" class="logo">
			<span class="icon">🌳</span>
			<span class="text">LiveTree</span>
		</a>

		<ul class="nav-links">
			<li>
				<a href="/" class:active={$page.url.pathname === '/'}>Dashboard</a>
			</li>
			<li>
				<a href="/trees" class:active={$page.url.pathname.startsWith('/trees')}>Trees</a>
			</li>
			<li>
				<a href="/insights" class:active={$page.url.pathname.startsWith('/insights')}>Insights</a>
			</li>
		</ul>

		<div class="user-menu">
			{#if user}
				<div class="avatar" onclick={signOut} title="Sign Out">
					{user.email?.charAt(0).toUpperCase()}
				</div>
			{:else}
				<a href="/signin" class="btn-signin">Sign In</a>
			{/if}
		</div>
	</div>
</nav>

<style>
	.navbar {
		background-color: rgba(255, 255, 255, 0.95);
		backdrop-filter: blur(10px);
		border-bottom: 1px solid rgba(0, 0, 0, 0.05);
		position: sticky;
		top: 0;
		z-index: 100;
		padding: 0.75rem 0;
	}

	.nav-container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 0 2rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.logo {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		text-decoration: none;
		font-weight: 800;
		font-size: 1.5rem;
		color: var(--primary-color);
		letter-spacing: -0.5px;
	}

	.logo .icon {
		font-size: 1.75rem;
	}

	.nav-links {
		display: flex;
		gap: 0.5rem;
		list-style: none;
		margin: 0;
		padding: 0;
		background: #f1f5f9;
		padding: 0.25rem;
		border-radius: 99px;
	}

	.nav-links a {
		text-decoration: none;
		color: var(--text-secondary);
		font-weight: 500;
		padding: 0.5rem 1.25rem;
		border-radius: 99px;
		transition: all 0.2s ease;
		font-size: 0.95rem;
		display: block;
	}

	.nav-links a:hover {
		color: var(--primary-color);
	}

	.nav-links a.active {
		background-color: white;
		color: var(--primary-color);
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
		font-weight: 600;
	}

	.avatar {
		width: 36px;
		height: 36px;
		background: var(--primary-color);
		color: white;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: 600;
		font-size: 0.9rem;
		cursor: pointer;
		transition: transform 0.2s;
	}

	.avatar:hover {
		transform: scale(1.05);
	}

	.btn-signin {
		background: var(--primary-color);
		color: white;
		padding: 0.5rem 1.25rem;
		border-radius: 8px;
		font-weight: 600;
		text-decoration: none;
		transition: all 0.2s ease;
		font-size: 0.9rem;
	}

	.btn-signin:hover {
		background: var(--primary-hover);
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(44, 95, 45, 0.3);
	}
</style>
