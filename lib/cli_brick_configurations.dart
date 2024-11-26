import 'package:devmy_cli/src/models/new_definition.dart';
import 'package:devmy_cli/src/models/utility_command_definition.dart';
import 'package:mason/mason.dart';

import 'package:devmy_cli/src/devmy_cli.dart';

final cliConfiguration = CliConfiguration(
  new$: NewCommandDefinition(
    brick: GitPath('https://github.com/acadevmy/scaffold-brick'),
    description: 'Easily create a Devmy scaffold masterpiece',
    questions: [
      Question(
        isOptional: true,
        prompt: 'What type of git repository do you want to use?',
        addonNames: ['gitlab'],
      ),
    ],
  ),
  applications: [
    ApplicationCommandDefinition(
      name: 'angular',
      brick: GitPath('https://github.com/acadevmy/angular-application-brick'),
      description:
          'Generate a fully-equipped Angular project in your workspace',
      aliases: ['ng'],
      questions: [
        Question(
          isOptional: true,
          prompt:
              'Which UI component library would you like to integrate into your Angular application?',
          addonNames: ['angular/tailwind'],
        ),
        Question(
          isOptional: true,
          prompt: 'Would you like to set up a deploy system?',
          addonNames: ['vercel'],
        ),
      ],
    ),
    ApplicationCommandDefinition(
      name: 'nextjs',
      brick: GitPath('https://github.com/acadevmy/next-application-brick'),
      description: 'Generate a fully-equipped Nextjs project in your workspace',
      questions: [
        Question(
          isOptional: true,
          prompt:
              'Which template would you like to configure for your Next.js project?',
          addonNames: ['next/commerce'],
        ),
        Question(
          isOptional: true,
          prompt:
              'Which UI component library would you like to integrate into your Next.js application?',
          addonNames: ['next/shadcnui'],
        ),
        Question(
          isOptional: true,
          prompt:
              'Which state management solution would you like to use in your Next.js application?',
          addonNames: ['next/zustand'],
        ),
        Question(
          isOptional: true,
          prompt:
              'Would you like to add a dynamic route to your Next.js application?',
          addonNames: ['next/dynamic-route'],
        ),
        Question(
          isOptional: true,
          prompt: 'Would you like to set up a deploy system?',
          addonNames: ['vercel'],
        ),
      ],
      aliases: ['next'],
    ),
    ApplicationCommandDefinition(
      name: "shopware",
      brick: GitPath("https://github.com/acadevmy/shopware-application-brick"),
      description:
          "Generate a starter to install Shopware 6, inside the container",
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
    ApplicationCommandDefinition(
      name: "firebase",
      brick: GitPath("https://github.com/acadevmy/firebase-application-brick"),
      description: "Generate a solid Firebase project in your workspace",
      aliases: ['fb'],
      questions: [
        Question(
          isOptional: true,
          prompt:
              'Would you like to add some applications to firebase hosting?',
          addonNames: ['firebase/hosting'],
        ),
      ],
    ),
  ],
  addons: [
    AddonCommandDefinition(
      name: 'next/commerce',
      brick: GitPath("https://github.com/acadevmy/nextjs-commerce-addon-brick"),
      description: "Configures the scaffold to support the ecommerce setup in your Next.js project.",
    ),
    
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
    AddonCommandDefinition(
      name: 'next/dynamic-route',
      brick:
          GitPath("https://github.com/acadevmy/next-dynamic-route-addon-brick"),
      description: "Create a dynamic route for your Next.js project",
      fileConflictResolution: FileConflictResolution.append,
    ),
    AddonCommandDefinition(
      name: 'angular/tailwind',
      brick:
          GitPath("https://github.com/acadevmy/angular-tailwind-addon-brick"),
      description: "Integrating TailwindCSS with Angular",
    ),
    AddonCommandDefinition(
      name: 'gitlab',
      aliases: ['gl'],
      brick: GitPath("https://github.com/acadevmy/scaffold-gitlab-addon-brick"),
      description: "Configure Gitlab",
    ),
    AddonCommandDefinition(
      name: 'vercel',
      aliases: ['vercello', 'marcello'],
      brick: GitPath("https://github.com/acadevmy/vercel_addon_brick"),
      description: "Configure Vercel",
    ),
    AddonCommandDefinition(
      name: 'firebase/hosting',
      brick:
          GitPath("https://github.com/acadevmy/firebase-hosting-addon-brick"),
      description: "Include application to firebase hosting",
    ),
  ],
  libraries: [
    LibraryCommandDefinition(
      name: 'typescript',
      aliases: ['ts'],
      brick: GitPath("https://github.com/acadevmy/typescript_library_brick"),
      description: "Generate a robust typescript library in your workspace",
    ),
    LibraryCommandDefinition(
      name: 'angular',
      aliases: ['ng'],
      brick: GitPath("https://github.com/acadevmy/angular_library_brick"),
      description: "Generate an angular library in your workspace",
    )
  ],
  utilities: [
    UtilityCommandDefinition(
      name: 'create-brick',
      brick: GitPath("https://github.com/acadevmy/devmy-cli-create-brick"),
      description: "Create new Devmy CLI brick",
    ),
  ],
);
