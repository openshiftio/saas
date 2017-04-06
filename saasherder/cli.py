#!/usr/bin/env python

import argparse

from saasherder import SaasHerder

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('-d', '--debug', default=False, action='store_true',
                        help='Run in debug mode')
    parser.add_argument('-D', '--templates-dir', default="templates",
                        help='Output directory where the downloaded templates are be stored')
    parser.add_argument('-s', '--service-dir', default="services",
                        help='A directory containing services definitions')
    subparsers = parser.add_subparsers(dest="command")
    subparser_pull = subparsers.add_parser("pull")
    subparser_pull.add_argument('service', nargs="*", default="all")

    subparser_update = subparsers.add_parser("update")
    subparser_update.add_argument('-o', '--output-file', default=None,
                                  help='Name of the output file for updated services yaml')
    subparser_update.add_argument('type', choices=["hash", "path"],
                                  help="What to update")
    subparser_update.add_argument('service', nargs="?", default=None,
                                  help="Service to be updated")
    subparser_update.add_argument('value',
                                  help="Value to be used in services yaml")

    subparser_template = subparsers.add_parser("template")
    #subparser_template.add_argument('--all', default=False, action='store_true',
    #                    help='Perform the action on all services')
    subparser_template.add_argument('--output-dir', default=None,
                        help='Output directory where the updated templates will be stored')
    subparser_template.add_argument("type", choices=["tag"],
                                    help="Update image tag with commit hash")
    subparser_template.add_argument("services", nargs="*", default="all",
                                    help="Service which template should be updated")      

    args = parser.parse_args()

    se = SaasHerder(args.service_dir, args.templates_dir)
    if args.command == "pull":
      if args.service:
        se.collect_services(args.service)
    elif args.command == "update":
      se.update(args.type, args.service, args.value, output_file=args.output_file)
    elif args.command == "template":
      se.template(args.type, args.services, args.output_dir)
