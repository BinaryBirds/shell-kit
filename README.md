# ShellKit (🥚)

Shell is a simple package that gives you the ability to call shell commands through Swift.

## Usage

Run (sync):

```swift
import ShellKit

let output = try Shell().run("ls ~")
```

Run (async):

```swift
import ShellKit

Shell().run("sleep 2 && ls ~") { result, error in
    //...
}
```

Shell (bash) with environment variables:

```swift
import ShellKit

let shell = Shell("/bin/bash", env: ["ENV_SAMPLE_KEY": "Hello world!"])
let out = try shell.run("echo $ENV_SAMPLE_KEY")
```

You can even set custom ouptut & error handlers.



## Install

Just use the [Swift Package Manager](https://theswiftdev.com/2017/11/09/swift-package-manager-tutorial/) as usual:

```swift
.package(url: "https://github.com/binarybirds/shell-kit", from: "1.0.0"),
```

Don't forget to add "ShellKit" to your target as a dependency:

```swift
.product(name: "ShellKit", package: "shell-kit"),
```

That's it.


## License

[WTFPL](LICENSE) - Do what the fuck you want to.
