FROM alpine

ENV TZ=Asia/Shanghai

WORKDIR /usr/src

RUN set -eux; \
	\
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
	sed -i 's/uk.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
	apk --no-cache --no-progress upgrade; \
	buildDeps=' \
		build-base \
		git \
		clang \
		cmake \
		openssl-dev \
		boost-dev \
		boost-static \
	'; \
    # apk add --no-cache linux-headers
	apk add --no-cache --virtual .build-deps \
		$buildDeps \
	;

RUN set -eux; \
	\
	git clone https://github.com/trojan-gfw/trojan trojan; \
	cd trojan; \
	echo 'target_link_libraries(trojan dl)' >> CMakeLists.txt; \
    echo 'target_link_libraries(trojan -static-libgcc -static-libstdc++)' >> CMakeLists.txt; \
	mkdir build; \
	cd build/; \
	CMAKE_OPTIONS=' \
		-DENABLE_MYSQL=OFF \
		-DENABLE_NAT=ON \
		-DENABLE_REUSE_PORT=ON \
		-DENABLE_SSL_KEYLOG=ON \
		-DENABLE_TLS13_CIPHERSUITES=ON \
		-DFORCE_TCP_FASTOPEN=OFF \
		-DSYSTEMD_SERVICE=OFF \
		-DOPENSSL_USE_STATIC_LIBS=TRUE \
		-DOPENSSL_INCLUDE_DIR=/usr/include \
		-DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.so \
		-DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.so \
		-DBoost_USE_STATIC_LIBS=ON \
		-DBoost_DEBUG=ON \
	'; \
	cmake $CMAKE_OPTIONS .. ; \
	make; \
	strip -s trojan

RUN set -eux; \
	\
	apk del .build-deps;

WORKDIR /usr/src/trojan/build
