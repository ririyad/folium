<script lang="ts">
	import { page } from '$app/stores';
</script>

<nav class="navbar">
	<div class="nav-container">
		<a href="/" class="nav-logo">Folium</a>
		<ul class="nav-links">
			<li>
				<a href="/" class:active={$page.url.pathname === '/'}>Home</a>
			</li>
			<li>
				<a href="/trees" class:active={$page.url.pathname.startsWith('/trees')}>Tree Management</a>
			</li>
			<li>
				<a href="/insights" class:active={$page.url.pathname.startsWith('/insights')}>Contribution Insights</a>
			</li>
		</ul>
	</div>
</nav>

<style>
	.navbar {
		background-color: #2c5f2d;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	.nav-container {
		max-width: 1200px;
		margin: 0 auto;
		padding: 0 20px;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.nav-logo {
		font-size: 1.5rem;
		font-weight: bold;
		color: #ffffff;
		text-decoration: none;
	}

	.nav-links {
		display: flex;
		list-style: none;
		gap: 2rem;
		margin: 0;
		padding: 1rem 0;
	}

	.nav-links a {
		color: #ffffff;
		text-decoration: none;
		font-weight: 500;
		padding: 0.5rem 1rem;
		border-radius: 4px;
		transition: background-color 0.2s ease;
	}

	.nav-links a:hover {
		background-color: rgba(255, 255, 255, 0.1);
	}

	.nav-links a.active {
		background-color: rgba(255, 255, 255, 0.2);
	}
</style>
