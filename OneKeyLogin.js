import {
  NativeModules,
  Platform,
  NativeEventEmitter,
} from 'react-native';

const OneKeyLogin = NativeModules.OneKeyLogin;

export {
  OneKeyLogin,
}

//########这是第二种登录方式#########
/**
 *获取移动端的token,然后把token发送给我们的服务器,在js端做登录
 *获取token的流程在原生端完成,与我们服务器的登录流程需要自己在js端完成
 * @param {*} [params={}] 给原生传递的参数,
 * @return {Promise<{}>}
 */
export const getLoginToken = (params = {
  userProtocol: "https://agreement.quectel.com/user_agreement_zh_CN.html",
  privacyProtocol: "https://agreement.quectel.com/privacy_agreement_zh_CN.html"
}) => {
  return OneKeyLogin.getLoginToken(params);
}
/**
 *消失一键登录页面
 *
 */
export const dismiss = () => {
  OneKeyLogin.dismiss();
}