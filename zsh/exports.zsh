#export HTTP_PROXY="http://localhost:10801"
#export HTTPS_PROXY="http://localhost:10801"
#export NO_PROXY="localhost,127.0.0.1,master,*.hypers.com,10.*"

export public_key_name="enihsyou.pub"
export REQUESTS_CA_BUNDLE="/Users/enihsyou/.ssh/ca/intermediate/certs/intermediate-chain.cert.pem"
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

export LDFLAGS="${LDFLAGS} -L/usr/local/opt/sqlite/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/sqlite/include"
