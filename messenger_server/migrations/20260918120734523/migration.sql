BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_device" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "clientId" uuid NOT NULL,
    "platform" text NOT NULL,
    "pushToken" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "messenger_device_client_unique_idx" ON "messenger_device" USING btree ("clientId");
CREATE INDEX "messenger_device_user_idx" ON "messenger_device" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_profile" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "aboutMe" text NOT NULL,
    "profileImageId" bigint,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "messenger_profile_user_unique_idx" ON "messenger_profile" USING btree ("userId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_device"
    ADD CONSTRAINT "messenger_device_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_profile"
    ADD CONSTRAINT "messenger_profile_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260918120734523', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260918120734523', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
