import "./style.css";
import { parse } from "./grammar.pegjs";

export default function ({ className = "fountainer" } = {}) {
  Array.from(document.getElementsByClassName(className)).forEach((el) => {
    const fountainString = el.innerHTML.trim();
    const tokens = parse(fountainString);
    el.innerHTML = JSON.stringify(tokens, null, "  ");
  });
}
