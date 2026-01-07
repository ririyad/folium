<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';

	let email = $state('');
	let password = $state('');
	let loading = $state(false);
	let error = $state<string | null>(null);

	async function signIn() {
		try {
			loading = true;
			error = null;

			const { data, error: signInError } = await supabase.auth.signInWithPassword({
				email,
				password
			});

			if (signInError) throw signInError;

			goto('/');
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to sign in';
		} finally {
			loading = false;
		}
	}

	async function signInWithGoogle() {
		try {
			loading = true;
			error = null;

			const { data, error: signInError } = await supabase.auth.signInWithOAuth({
				provider: 'google',
				options: {
					redirectTo: `${window.location.origin}/auth/callback`
				}
			});

			if (signInError) throw signInError;
		} catch (err) {
			error = err instanceof Error ? err.message : 'Failed to sign in with Google';
			loading = false;
		}
	}
</script>

<div class="auth-container">
	<div class="auth-card">
		<div class="logo-section">
			<span class="icon">🌳</span>
			<h1>LiveTree</h1>
			<p>Sign in to your account</p>
		</div>

		{#if error}
			<div class="error-banner">
				<span class="error-icon">⚠️</span>
				<p>{error}</p>
			</div>
		{/if}

		<form onsubmit={(e) => e.preventDefault(); signIn()}>
			<div class="form-group">
				<label for="email">Email</label>
				<input
					id="email"
					type="email"
					bind:value={email}
					placeholder="you@example.com"
					required
					autocomplete="email"
				/>
			</div>

			<div class="form-group">
				<label for="password">Password</label>
				<input
					id="password"
					type="password"
					bind:value={password}
					placeholder="•••••••••"
					required
					autocomplete="current-password"
				/>
			</div>

			<button type="submit" class="btn btn-primary btn-full" disabled={loading}>
				{#if loading}
					<span class="spinner"></span>
				{:else}
					Sign In
				{/if}
			</button>
		</form>

		<div class="divider">
			<span>or continue with</span>
		</div>

		<button class="btn btn-google" onclick={signInWithGoogle} disabled={loading}>
			<svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
				<path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09 0-4.36-3.54-7.9-7.9-7.9-4.36 0-7.9 3.54-7.9 7.9 0 2.86 1.48 5.38 3.74 6.83L2.8 16.1a7.9 7.9 0 0 0 7.5 5.5h.03v-.04z"/>
			</svg>
			Continue with Google
		</button>

		<p class="auth-footer">
			Don't have an account?
			<a href="/signup">Sign up for free</a>
		</p>
	</div>
</div>

<style>
	.auth-container {
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		background: linear-gradient(135deg, var(--background-color) 0%, #e8f5e9 100%);
		padding: 2rem;
	}

	.auth-card {
		background: white;
		border-radius: 24px;
		box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
		padding: 3rem;
		width: 100%;
		max-width: 450px;
	}

	.logo-section {
		text-align: center;
		margin-bottom: 2.5rem;
	}

	.logo-section .icon {
		font-size: 3rem;
		display: block;
		margin-bottom: 1rem;
	}

	.logo-section h1 {
		font-size: 2rem;
		color: var(--primary-color);
		margin: 0 0 0.5rem 0;
		font-weight: 800;
	}

	.logo-section p {
		color: var(--text-secondary);
		margin: 0;
		font-size: 1rem;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-group label {
		display: block;
		margin-bottom: 0.5rem;
		color: var(--text-primary);
		font-weight: 600;
		font-size: 0.9rem;
	}

	.form-group input {
		width: 100%;
		padding: 0.875rem 1rem;
		border: 2px solid #e2e8f0;
		border-radius: 12px;
		font-size: 1rem;
		transition: all 0.2s ease;
		font-family: var(--font-main);
	}

	.form-group input:focus {
		outline: none;
		border-color: var(--primary-color);
		box-shadow: 0 0 0 3px rgba(44, 95, 45, 0.1);
	}

	.error-banner {
		background: #fef2f2;
		border: 1px solid #fecaca;
		color: #991b1b;
		padding: 1rem;
		border-radius: 12px;
		display: flex;
		gap: 0.75rem;
		align-items: flex-start;
		margin-bottom: 1.5rem;
	}

	.error-icon {
		font-size: 1.25rem;
	}

	.btn {
		width: 100%;
		padding: 1rem;
		border-radius: 12px;
		font-weight: 600;
		font-size: 1rem;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.75rem;
		transition: all 0.2s ease;
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.btn-primary {
		background: var(--primary-color);
		color: white;
		border: none;
	}

	.btn-primary:hover:not(:disabled) {
		background: var(--primary-hover);
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(44, 95, 45, 0.3);
	}

	.btn-google {
		background: white;
		color: var(--text-primary);
		border: 2px solid #e2e8f0;
	}

	.btn-google:hover:not(:disabled) {
		background: #f8fafc;
		border-color: #cbd5e1;
	}

	.divider {
		display: flex;
		align-items: center;
		margin: 2rem 0;
		color: var(--text-secondary);
		font-size: 0.875rem;
	}

	.divider::before,
	.divider::after {
		content: '';
		flex: 1;
		height: 1px;
		background: #e2e8f0;
	}

	.divider span {
		padding: 0 1rem;
	}

	.auth-footer {
		text-align: center;
		margin-top: 2rem;
		color: var(--text-secondary);
		font-size: 0.95rem;
	}

	.auth-footer a {
		color: var(--primary-color);
		text-decoration: none;
		font-weight: 600;
	}

	.auth-footer a:hover {
		text-decoration: underline;
	}

	.spinner {
		width: 20px;
		height: 20px;
		border: 2px solid rgba(255, 255, 255, 0.3);
		border-top-color: white;
		border-radius: 50%;
		animation: spin 0.8s linear infinite;
	}

	@keyframes spin {
		0% { transform: rotate(0deg); }
		100% { transform: rotate(360deg); }
	}
</style>
