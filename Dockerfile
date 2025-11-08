# ========== Stage 1: Build static libpcap and naabu ==========
FROM ubuntu:24.04 AS builder

# Instala herramientas y dependencias para compilar libpcap y Go
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget build-essential git gcc make pkg-config ca-certificates curl flex bison

# Instala Go
ARG GO_VERSION=1.22.4
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tgz \
    && tar -C /usr/local -xzf /tmp/go.tgz && rm /tmp/go.tgz
ENV PATH=/usr/local/go/bin:$PATH

# Descarga y compila libpcap estática
ARG LIBPCAP_VERSION=1.10.5
WORKDIR /tmp
RUN wget https://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz \
    && tar -xzf libpcap-${LIBPCAP_VERSION}.tar.gz \
    && cd libpcap-${LIBPCAP_VERSION} \
    && ./configure --enable-static --disable-shared --with-pcap=linux \
    && make -j$(nproc) && make install

# Variables de entorno para enlace estático
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-I/usr/local/include"
ENV CGO_LDFLAGS="-L/usr/local/lib -static"

# Clona el código fuente del proyecto en lugar de copiarlo
WORKDIR /app
RUN git clone https://github.com/projectdiscovery/naabu.git
WORKDIR /app/naabu

# Descarga dependencias de Go
RUN go mod download

# Compila naabu con enlace completamente estático
RUN GOOS=linux GOARCH=amd64 \
    go build -v -ldflags="-s -w -extldflags '-static'" -o /naabu ./cmd/naabu

# Verifica que sea estático (solo para diagnóstico)
RUN ldd /naabu || true

# ========== Stage 2: Minimal runtime ==========
FROM scratch
COPY --from=builder /naabu /usr/local/bin/naabu
ENTRYPOINT ["/usr/local/bin/naabu"]
