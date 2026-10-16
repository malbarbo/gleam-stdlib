import { readdirSync, readFileSync } from "node:fs";
import process from "node:process";
import { instantiate, Exit } from "./gleam.mjs";

// Called by the WebAssembly program, which can't wait for the tests, so they
// run after it returns, like on JavaScript.
export function main() {
  run();
}

async function run() {
  let passed = 0;
  let failed = 0;

  let packageName = readRootPackageName();
  let dist = new URL(`../${packageName}/`, import.meta.url);

  for (let path of gleamFiles("test")) {
    let modulePath = path.slice("test/".length).replace(/\.gleam$/, "");
    let instance;
    try {
      instance = await instantiate(new URL(`${modulePath}.wasm`, dist));
    } catch (error) {
      failed += 1;
      report(modulePath, error);
      continue;
    }
    for (let [name, value] of Object.entries(instance.exports)) {
      if (!name.endsWith("_test") || typeof value !== "function") continue;
      try {
        value();
        passed += 1;
        process.stdout.write(green("."));
      } catch (error) {
        failed += 1;
        report(`${modulePath}.${name}`, error);
      }
    }
  }

  process.exit(finished(passed, failed));
}

function report(name, error) {
  // A panic prints its message before exiting.
  if (!(error instanceof Exit)) console.error(error);
  process.stdout.write(`\n${red(`${name} failed`)}\n`);
}

function finished(passed, failed) {
  if (passed + failed === 0) {
    console.log("\nNo tests found!");
    return 1;
  }
  if (failed === 0) {
    console.log(`\n${green(`${passed} passed, no failures`)}`);
    return 0;
  }
  console.log(`\n${red(`${passed} passed, ${failed} failures`)}`);
  return 1;
}

function* gleamFiles(directory) {
  for (let entry of readdirSync(directory, { withFileTypes: true })) {
    let path = `${directory}/${entry.name}`;
    if (entry.isDirectory()) {
      yield* gleamFiles(path);
    } else if (path.endsWith(".gleam")) {
      yield path;
    }
  }
}

function readRootPackageName() {
  let toml = readFileSync("gleam.toml", "utf-8");
  for (let line of toml.split("\n")) {
    let matches = line.match(/\s*name\s*=\s*"([a-z][a-z0-9_]*)"/); // Match regexp in compiler-cli/src/new.rs in validate_name()
    if (matches) return matches[1];
  }
  throw new Error("Could not determine package name from gleam.toml");
}

function green(text) {
  return `\u001b[32m${text}\u001b[39m`;
}

function red(text) {
  return `\u001b[31m${text}\u001b[39m`;
}
