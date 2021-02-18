#!/bin/bash
echo "[$0] Generating keys for CAS...";

if [ ! -z "${DOCKER_SKIP_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_CONFIGURATION is defined, skipping this script.";
  exit;
fi

cd "/casstart/"

java -jar jwk-gen.jar -t oct -s 512 -o cryptosigkeyfile -u sig
cryptosigkey=$(cat cryptosigkeyfile | jq -r '.k')
rm cryptosigkeyfile
echo "[$0] Generated signing key for CAS...";

java -jar jwk-gen.jar -t oct -s 128 -o cryptoenckeyfile -u enc
cryptoenckey=$(cat cryptoenckeyfile | jq -r '.k')
rm cryptoenckeyfile
echo "[$0] Generated encryption key for CAS...";

java -jar jwk-gen.jar -t oct -s 512 -o tgccryptosigkeyfile -u sig
tgccryptosigkey=$(cat tgccryptosigkeyfile | jq -r '.k')
rm tgccryptosigkeyfile
echo "[$0] Generated signing key for CAS...";

java -jar jwk-gen.jar -t oct -s 256 -o tgccryptoenckeyfile -u enc
tgccryptoenckey=$(cat tgccryptoenckeyfile | jq -r '.k')
rm tgccryptoenckeyfile
echo "[$0] Generated encryption key for CAS...";

java -jar jwk-gen.jar -t oct -s 512 -o oauthatsigkeyfile -u sig
oauthatsigkey=$(cat oauthatsigkeyfile | jq -r '.k')
rm oauthatsigkeyfile
echo "[$0] Generated signing key for CAS...";

java -jar jwk-gen.jar -t oct -s 256 -o oauthatenckeyfile -u enc
oauthatenckey=$(cat oauthatenckeyfile | jq -r '.k')
rm oauthatenckeyfile
echo "[$0] Generated encryption key for CAS...";

java -jar jwk-gen.jar -t oct -s 512 -o oauthcryptosigkeyfile -u sig
oauthcryptosigkey=$(cat oauthcryptosigkeyfile | jq -r '.k')
rm oauthcryptosigkeyfile
echo "[$0] Generated signing key for CAS...";

java -jar jwk-gen.jar -t oct -s 256 -o oauthcryptoenckeyfile -u enc
oauthcryptoenckey=$(cat oauthcryptoenckeyfile | jq -r '.k')
rm oauthcryptoenckeyfile
echo "[$0] Generated encryption key for CAS...";

cd "$CAS_CONFIG";
sed -i "s#.*cas.webflow.crypto.signing.key=.*#cas.webflow.crypto.signing.key=$cryptosigkey#" cas.properties;
sed -i "s#.*cas.webflow.crypto.encryption.key=.*#cas.webflow.crypto.encryption.key=$cryptoenckey#" cas.properties;
sed -i "s#.*cas.tgc.crypto.signing.key=.*#cas.tgc.crypto.signing.key=$tgccryptosigkey#" cas.properties;
sed -i "s#.*cas.tgc.crypto.encryption.key=.*#cas.tgc.crypto.encryption.key=$tgccryptoenckey#" cas.properties;
sed -i "s#.*cas.authn.oauth.accessToken.crypto.signing.key=.*#cas.authn.oauth.accessToken.crypto.signing.key=$oauthatsigkey#" cas.properties;
sed -i "s#.*cas.authn.oauth.accessToken.crypto.encryption.key=.*#cas.authn.oauth.accessToken.crypto.encryption.key=$oauthatenckey#" cas.properties;
sed -i "s#.*cas.authn.oauth.crypto.signing.key=.*#cas.authn.oauth.crypto.signing.key=$oauthcryptosigkey#" cas.properties;
sed -i "s#.*cas.authn.oauth.crypto.encryption.key=.*#cas.authn.oauth.crypto.encryption.key=$oauthcryptoenckey#" cas.properties;
echo "[$0] Saved keys to CAS properties...";











