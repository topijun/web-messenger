BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_message" (
    "id" bigserial PRIMARY KEY,
    "chatId" bigint NOT NULL,
    "senderId" bigint NOT NULL,
    "type" text NOT NULL,
    "encryptedText" text NOT NULL,
    "mediaId" bigint,
    "pollId" bigint,
    "createdAt" timestamp without time zone NOT NULL,
    "editedAt" timestamp without time zone,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "messenger_message_chat_created_idx" ON "messenger_message" USING btree ("chatId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_message_receipt" (
    "id" bigserial PRIMARY KEY,
    "messageId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "deliveredAt" timestamp without time zone,
    "readAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "messenger_message_receipt_unique_idx" ON "messenger_message_receipt" USING btree ("messageId", "userId");
CREATE INDEX "messenger_message_receipt_user_idx" ON "messenger_message_receipt" USING btree ("userId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_message"
    ADD CONSTRAINT "messenger_message_fk_0"
    FOREIGN KEY("chatId")
    REFERENCES "messenger_chat"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_message"
    ADD CONSTRAINT "messenger_message_fk_1"
    FOREIGN KEY("senderId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_message_receipt"
    ADD CONSTRAINT "messenger_message_receipt_fk_0"
    FOREIGN KEY("messageId")
    REFERENCES "messenger_message"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_message_receipt"
    ADD CONSTRAINT "messenger_message_receipt_fk_1"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260920100437172', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260920100437172', "timestamp" = now();

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
