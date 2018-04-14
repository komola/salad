FROM node:8

WORKDIR /opt/salad

#RUN apt-get update && apt-get install -y --no-install-recommends \
#		libpcsclite1 \
#		libpcsclite-dev \
#		graphicsmagick \
#		imagemagick \
#		libimage-exiftool-perl \
#	&& rm -rf /var/lib/apt/lists/*

COPY package.json /opt/salad/
RUN npm install

COPY . /opt/salad

CMD [ "npm", "test" ]
