import 'package:mason/mason.dart';

import 'package:devmy_cli/src/devmy_cli.dart';

final cliConfiguration = CliConfiguration(
  new$: NewCommand(
    brick: GitPath('https://github.com/acadevmy/scaffold-brick'),
    description:
        'Create a Devmy masterpiece with ease! This command sets up a comprehensive scaffold, ready to unleash your creativity.',
  ),
  applications: [
    ApplicationCommand(
      name: 'angular',
      brick: GitPath('https://github.com/acadevmy/angular-application-brick'),
      description:
          'Craft Angular brilliance effortlessly! Generate a fully-equipped Angular project in your workspace, paving the way for seamless development.',
    ),
    ApplicationCommand(
      name: 'next',
      brick: GitPath('https://github.com/acadevmy/next-application-brick'),
      description:
          'Embark on your next application adventure! Generate a Next.js application in your workspace, propelling your development journey forward.',
      questions: [
        Question(
            isOptional: true,
            prompt:
                'Which styling system would you like to use in your Next.js project?',
            addonNames: ['next/tailwind']),
        Question(
            isOptional: true,
            prompt:
                'Which state management solution would you like to use in your Next.js project?',
            addonNames: ['next/zustand']),
      ],
    ),
    ApplicationCommand(
      brick: GitPath("https://github.com/acadevmy/directus-application-brick"),
      description: "Directus",
      name: "directus",
    ),
  ],
  addons: [
    AddonCommand(
        name: 'next/tailwind',
        brick: GitPath("https://github.com/acadevmy/next-tailwind-addon-brick"),
        description: "Enhance your Next.js project with Tailwind CSS"),
    AddonCommand(
      name: 'next/zustand',
      brick: GitPath("https://github.com/acadevmy/next_zustand_addon_brick"),
      description: "Integrating Zustand with Next.js",
    ),
  ],
);
