<script lang="ts">
	import { page } from '$app/stores';
</script>

<nav class="navbar">
	<div class="nav-container">
		<a href="/" class="logo">
			<span class="icon">🌿</span>
			<span class="text">Folium</span>
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
			<!-- Placeholder for user profile/avatar -->
			<div class="avatar">A</div>
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
</style>
