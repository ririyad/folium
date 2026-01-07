// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		interface Locals {
			user?: {
				id: string;
				email: string;
				role: 'admin' | 'volunteer' | 'viewer';
			};
		}
	}
}

interface ImportMetaEnv {
	VITE_SUPABASE_URL: string;
	VITE_SUPABASE_ANON_KEY: string;
}

interface ImportMeta {
	readonly env: ImportMetaEnv;
}

export {};
