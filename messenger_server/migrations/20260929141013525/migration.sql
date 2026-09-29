BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_message_reaction" (
    "id" bigserial PRIMARY KEY,
    "messageId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "emoji" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "messenger_message_reaction_unique_idx" ON "messenger_message_reaction" USING btree ("messageId", "userId", "emoji");
CREATE INDEX "messenger_message_reaction_message_idx" ON "messenger_message_reaction" USING btree ("messageId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_message_reaction"
    ADD CONSTRAINT "messenger_message_reaction_fk_0"
    FOREIGN KEY("messageId")
    REFERENCES "messenger_message"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_message_reaction"
    ADD CONSTRAINT "messenger_message_reaction_fk_1"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260929141013525', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260929141013525', "timestamp" = now();

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
