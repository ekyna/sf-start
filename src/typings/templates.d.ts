interface Template {
    render({data: any}): string
}

declare let Templates:{[id:string]: Template};

declare module "web/shop/templates" {
    export = Templates;
}
