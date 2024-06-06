import 'package:devmy_cli/src/models/new_definition.dart';
import 'package:mason/mason.dart';

import 'package:devmy_cli/src/devmy_cli.dart';

final cliConfiguration = CliConfiguration(
  new$: NewCommandDefinition(
    brick: GitPath('https://github.com/acadevmy/scaffold-brick'),
    description: 'Easily create a Devmy scaffold masterpiece',
  ),
  applications: [
    ApplicationCommandDefinition(
      name: 'angular',
      brick: GitPath('https://github.com/acadevmy/angular-application-brick'),
      description:
          'Generate a fully-equipped Angular project in your workspace',
      aliases: ['ng'],
    ),
    ApplicationCommandDefinition(
      name: 'nextjs',
      brick: GitPath('https://github.com/acadevmy/next-application-brick'),
      description: 'Generate a fully-equipped Nextjs project in your workspace',
      questions: [
        Question(
          isOptional: true,
          prompt:
              'Which UI component library would you like to integrate into your Next.js project?',
          addonNames: ['next/shadcnui'],
        ),
        Question(
          isOptional: true,
          prompt:
              'Which state management solution would you like to use in your Next.js project?',
          addonNames: ['next/zustand'],
        ),
      ],
      aliases: ['next'],
    ),
    ApplicationCommandDefinition(
      name: "directus",
      brick: GitPath("https://github.com/acadevmy/directus-application-brick"),
      description:
          "Generate a fully-equipped Directus project in your workspace",
    ),
    ApplicationCommandDefinition(
      name: "nestjs",
      brick: GitPath("https://github.com/acadevmy/nestjs-application-brick"),
      description: "Generate a fully-equipped NestJS project in your workspace",
      aliases: ['nest'],
    ),
    ApplicationCommandDefinition(
      name: "cypress",
      brick: GitPath("https://github.com/acadevmy/cypress-application-brick"),
      description: "Generate an armored Cypress project in your workspace",
      aliases: ['cy', 'cipresso'],
    ),
  ],
  addons: [
    AddonCommandDefinition(
      name: 'next/zustand',
      brick: GitPath("https://github.com/acadevmy/next-zustand-addon-brick"),
      description: "Integrating Zustand with Next.js",
    ),
    AddonCommandDefinition(
      name: 'next/shadcnui',
      brick: GitPath("https://github.com/acadevmy/next-shacnui-addon-brick"),
      description: "Customizable UI for Next.js with ShadcnUI.",
    ),
  ],
);
