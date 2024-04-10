import 'package:mason/mason.dart';

import 'package:devmy_cli/src/devmy_cli.dart';

final cliConfiguration = CliConfiguration(
  new$: NewCommand(
    brick: GitPath('https://gitlab.com/pillar-1/scaffold-brick'),
    description:
        'Create a Devmy masterpiece with ease! This command sets up a comprehensive scaffold, ready to unleash your creativity.',
  ),
  applications: [
    ApplicationCommand(
      name: 'angular',
      brick: GitPath('https://gitlab.com/pillar-1/scaffold-brick'),
      description:
          'Craft Angular brilliance effortlessly! Generate a fully-equipped Angular project in your workspace, paving the way for seamless development.',
    ),
    ApplicationCommand(
      name: 'next',
      brick: GitPath('https://gitlab.com/pillar-1/scaffold-brick'),
      description:
          'Embark on your next application adventure! Generate a Next.js application in your workspace, propelling your development journey forward.',
    ),
  ],
);
