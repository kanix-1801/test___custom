// @ts-check

import { LightningElement, api } from "lwc";

export default class StyleOverwrite extends LightningElement {
  @api cssString;

  renderedCallback() {
    const styleContainer = this.template.querySelector("div.style-overwrite__style-container");
    const styleTag = `
            <style>
                ${this.cssString}
            </style>
        `;

    console.log(this.cloneObject({
      styleContainer,
      styleTag
    }));

    styleContainer.innerHTML = styleTag;
  }

  cloneObject(obj) {
    return JSON.parse(JSON.stringify(obj));
  }
}