import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    outDir: 'dist'
  },
  server: {
    proxy: {
      '/tty': {
        target: 'ws://localhost:8080',
        ws: true
      }
    }
  }
})
