
# react-native-app-lib-test

## Getting started

`$ npm install react-native-app-lib-test --save`

### Mostly automatic installation

`$ react-native link react-native-app-lib-test`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-app-lib-test` and add `RNAppLibTest.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNAppLibTest.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.quenice.apptest.RNAppLibTestPackage;` to the imports at the top of the file
  - Add `new RNAppLibTestPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-app-lib-test'
  	project(':react-native-app-lib-test').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-app-lib-test/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-app-lib-test')
  	```


## Usage
```javascript
import RNAppLibTest from 'react-native-app-lib-test';

// TODO: What to do with the module?
RNAppLibTest;
```
  