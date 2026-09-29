BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_chat" (
    "id" bigserial PRIMARY KEY,
    "type" text NOT NULL,
    "name" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastMessageAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "messenger_chat_last_message_idx" ON "messenger_chat" USING btree ("lastMessageAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_chat_invitation" (
    "id" bigserial PRIMARY KEY,
    "chatId" bigint,
    "senderId" bigint NOT NULL,
    "receiverId" bigint NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "messenger_chat_invitation_receiver_status_idx" ON "messenger_chat_invitation" USING btree ("receiverId", "status");
CREATE INDEX "messenger_chat_invitation_sender_idx" ON "messenger_chat_invitation" USING btree ("senderId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_chat_participant" (
    "id" bigserial PRIMARY KEY,
    "chatId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "role" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "archived" boolean NOT NULL DEFAULT false,
    "notificationsMuted" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE UNIQUE INDEX "messenger_chat_participant_unique_idx" ON "messenger_chat_participant" USING btree ("chatId", "userId");
CREATE INDEX "messenger_chat_participant_user_idx" ON "messenger_chat_participant" USING btree ("userId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_chat_invitation"
    ADD CONSTRAINT "messenger_chat_invitation_fk_0"
    FOREIGN KEY("chatId")
    REFERENCES "messenger_chat"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_chat_invitation"
    ADD CONSTRAINT "messenger_chat_invitation_fk_1"
    FOREIGN KEY("senderId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_chat_invitation"
    ADD CONSTRAINT "messenger_chat_invitation_fk_2"
    FOREIGN KEY("receiverId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_chat_participant"
    ADD CONSTRAINT "messenger_chat_participant_fk_0"
    FOREIGN KEY("chatId")
    REFERENCES "messenger_chat"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_chat_participant"
    ADD CONSTRAINT "messenger_chat_participant_fk_1"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260918122126630', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260918122126630', "timestamp" = now();

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
