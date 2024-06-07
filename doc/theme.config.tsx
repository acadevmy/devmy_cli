import { DocsThemeConfig } from 'nextra-theme-docs'
import Logo from '@/components/Logo';

const config: DocsThemeConfig = {
    logo: <Logo/>,
    project: {
        link: 'https://github.com/acadevmy/devmy_cli',
    },
    docsRepositoryBase: 'https://github.com/acadevmy/devmy_cli/tree/main/doc',
    head: `
    <link
      rel="icon"
      href="/favicon.ico"
      type="image/x-icon"
    />
  `
}

export default config;
