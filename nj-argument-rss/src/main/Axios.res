
type axiosRes = {
  responseUrl: string
}
type axiosRequest = {
  res: axiosRes
}
type axiosResponse<'t> = {
  data: 't,
  request: axiosRequest
}

module Axios = {
  module Default = {
    type t = {
      "get": 't. string => promise<axiosResponse<'t>>
    }
  }
  
  type t = {
    "default": Default.t
  }
}

@module external axios: Axios.t = "axios"

let get: 't. string => promise<axiosResponse<'t>> = url => axios["default"]["get"](url)

