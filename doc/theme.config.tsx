import { DocsThemeConfig } from 'nextra-theme-docs'
import Logo from './components/Logo';

const config: DocsThemeConfig = {
  logo: <Logo />,
  project: {
    link: 'https://github.com/acadevmy/devmy_cli',
  },
  docsRepositoryBase: 'https://github.com/acadevmy/devmy_cli',
}

export default config
