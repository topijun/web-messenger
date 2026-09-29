BEGIN;

--
-- ACTION ALTER TABLE
--
--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_poll" (
    "id" bigserial PRIMARY KEY,
    "question" text NOT NULL,
    "anonymous" boolean NOT NULL DEFAULT false,
    "createdById" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "messenger_poll_created_by_idx" ON "messenger_poll" USING btree ("createdById");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_poll_option" (
    "id" bigserial PRIMARY KEY,
    "pollId" bigint NOT NULL,
    "text" text NOT NULL,
    "position" bigint NOT NULL
);

-- Indexes
CREATE INDEX "messenger_poll_option_order_idx" ON "messenger_poll_option" USING btree ("pollId", "position");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "messenger_poll_vote" (
    "id" bigserial PRIMARY KEY,
    "pollId" bigint NOT NULL,
    "optionId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "messenger_poll_vote_unique_idx" ON "messenger_poll_vote" USING btree ("pollId", "userId");
CREATE INDEX "messenger_poll_vote_option_idx" ON "messenger_poll_vote" USING btree ("optionId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_message"
    ADD CONSTRAINT "messenger_message_fk_3"
    FOREIGN KEY("pollId")
    REFERENCES "messenger_poll"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_poll"
    ADD CONSTRAINT "messenger_poll_fk_0"
    FOREIGN KEY("createdById")
    REFERENCES "messenger_user"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_poll_option"
    ADD CONSTRAINT "messenger_poll_option_fk_0"
    FOREIGN KEY("pollId")
    REFERENCES "messenger_poll"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "messenger_poll_vote"
    ADD CONSTRAINT "messenger_poll_vote_fk_0"
    FOREIGN KEY("pollId")
    REFERENCES "messenger_poll"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_poll_vote"
    ADD CONSTRAINT "messenger_poll_vote_fk_1"
    FOREIGN KEY("optionId")
    REFERENCES "messenger_poll_option"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "messenger_poll_vote"
    ADD CONSTRAINT "messenger_poll_vote_fk_2"
    FOREIGN KEY("userId")
    REFERENCES "messenger_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR messenger
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('messenger', '20260929132532929', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260929132532929', "timestamp" = now();

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
