declare module Guiders {
    interface Button {
        name: string
        onclick?: Function
        classString?: string
    }

    interface Settings {
        title: string
        description: string
        buttons: Array<Button>
        attachTo?: string
        autoFocus?: boolean
        buttonCustomHTML?: string
        classString?: string
        closeOnEscape?: boolean
        highlight?: string|JQuery
        isHashable?: boolean
        maxWidth?: number
        offset?: {top?: number, left?: number}
        onClose?: Function
        onHide?: Function
        onShow?: Function
        overlay?: boolean
        position?: 1|2|3|4|5|6|7|8|9|10|11|12
        shouldSkip?: Function
        width?: number
        xButton?: boolean
    }

    interface Guide extends Settings {
        id: string
        next?: string
    }

    class Guiders {
        _defaultSettings: Settings;

        createGuider(config: Guide)
        prev()
        next()
        hideAll()
    }
}

declare let guiders:Guiders.Guiders;

declare module 'guiders' {
    export = guiders;
}
