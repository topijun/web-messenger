BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_media" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "type" text NOT NULL,
    "mimeType" text NOT NULL,
    "size" bigint NOT NULL,
    "encryptedData" bytea NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "messenger_media_user_idx" ON "messenger_media" USING btree ("userId");

--
-- ACTION ALTER TABLE
--
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_media"
    ADD CONSTRAINT "messenger_media_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_profile"
    ADD CONSTRAINT "messenger_profile_fk_1"
    FOREIGN KEY("profileImageId")
    REFERENCES "messenger_media"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260921100855877', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260921100855877', "timestamp" = now();

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
