// Handling user input
// Displaying data

import type { Context } from "hono";
import { getUserController, type GetUserControllerErrors } from "./controller";
import { CommonErrors } from "~/shared/common/errors";
import type { Maybe } from "~/shared/common/types";
import type { User } from "~/shared/infrastructure/database/models/users";
import { Err, match, Result } from "oxide.ts";
import { UserErrors } from "@/users/users.errors";

type GetUserViewErrors =
  | GetUserControllerErrors
  | CommonErrors.ClientError
  | CommonErrors.ServerError
  | CommonErrors.UnexpectedServerError;

const buildResponse = ({ error, data }: { error?: Maybe<GetUserViewErrors>; data?: Maybe<User> }) => ({
  error,
  data,
  success: !Boolean(error),
});

export const getUserView = async (context: Context) => {
  let getUserResult: Result<User, GetUserViewErrors>;
  try {
    getUserResult = await getUserController(context.req.query());
  } catch (err) {
    getUserResult = Err(CommonErrors.ServerError);
  }

  return match(getUserResult, {
    Ok: (data: User) => {
      context.status(200);
      return context.json(buildResponse({ data }));
    },
    Err: [
      [
        CommonErrors.ClientError,
        (err) => {
          context.status(400);
          return context.json(buildResponse({ error: err }));
        },
      ],
      [
        UserErrors.UserNotFound,
        (err) => {
          context.status(404);
          return context.json(buildResponse({ error: err }));
        },
      ],
      [
        CommonErrors.ServerError,
        (err) => {
          context.status(500);
          return context.json(buildResponse({ error: err }));
        },
      ],
    ],
    _: () => {
      context.status(500);
      return context.json(buildResponse({ error: CommonErrors.UnexpectedServerError }));
    },
  });
};